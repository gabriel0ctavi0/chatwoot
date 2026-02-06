class Whatsapp::TemplateManagementService
  WHATSAPP_API_VERSION = 'v23.0'.freeze
  VALID_CATEGORIES = %w[MARKETING UTILITY AUTHENTICATION].freeze

  def initialize(whatsapp_channel)
    @whatsapp_channel = whatsapp_channel
  end

  def list_templates(status: nil)
    url = "#{business_account_path}/message_templates?access_token=#{api_key}"
    url += "&status=#{status}" if status.present?
    url += '&fields=name,category,status,language,components,id'

    templates = fetch_all_templates(url)
    { success: true, templates: templates }
  rescue StandardError => e
    Rails.logger.error "[WhatsApp TemplateManagement] list_templates failed: #{e.message}"
    { success: false, error: e.message }
  end

  def create_template(params)
    request_body = build_create_request_body(params)
    response = HTTParty.post(
      "#{business_account_path}/message_templates",
      headers: api_headers,
      body: request_body.to_json
    )

    if response.success?
      sync_templates_async
      { success: true, template_id: response['id'], template_name: params[:name], status: 'PENDING' }
    else
      Rails.logger.error "[WhatsApp TemplateManagement] create_template failed: #{response.code} - #{response.body}"
      { success: false, error: 'Template creation failed', response_body: response.body }
    end
  end

  def update_template(template_id, params)
    request_body = build_update_request_body(params)
    response = HTTParty.post(
      "#{api_base_path}/#{WHATSAPP_API_VERSION}/#{template_id}",
      headers: api_headers,
      body: request_body.to_json
    )

    if response.success?
      sync_templates_async
      { success: true }
    else
      Rails.logger.error "[WhatsApp TemplateManagement] update_template failed: #{response.code} - #{response.body}"
      { success: false, error: 'Template update failed', response_body: response.body }
    end
  end

  def delete_template(template_name, template_id: nil)
    url = "#{business_account_path}/message_templates?name=#{template_name}"
    url += "&hsm_id=#{template_id}" if template_id.present?

    response = HTTParty.delete(url, headers: api_headers)

    if response.success?
      sync_templates_async
      { success: true }
    else
      Rails.logger.error "[WhatsApp TemplateManagement] delete_template failed: #{response.code} - #{response.body}"
      { success: false, error: 'Template deletion failed', response_body: response.body }
    end
  end

  def upload_media(file_path, content_type, file_name)
    app_id = fetch_app_id
    raise 'Could not determine App ID from access token' if app_id.blank?

    file_size = File.size(file_path)
    session_id = create_upload_session(app_id, file_name, file_size, content_type)
    raise "Failed to create upload session: #{session_id}" if session_id.blank?

    handle = upload_file_to_session(session_id, file_path)
    raise "Failed to upload file: no handle returned" if handle.blank?

    { success: true, handle: handle }
  rescue StandardError => e
    Rails.logger.error "[WhatsApp TemplateManagement] upload_media failed: #{e.message}"
    { success: false, error: e.message }
  end

  private

  def fetch_app_id
    response = HTTParty.get(
      "#{api_base_path}/#{WHATSAPP_API_VERSION}/debug_token",
      query: { input_token: api_key, access_token: api_key }
    )
    response.dig('data', 'app_id')
  end

  def create_upload_session(app_id, file_name, file_length, file_type)
    response = HTTParty.post(
      "#{api_base_path}/#{WHATSAPP_API_VERSION}/#{app_id}/uploads",
      query: {
        file_name: file_name,
        file_length: file_length,
        file_type: file_type,
        access_token: api_key
      }
    )
    Rails.logger.info "[WhatsApp TemplateManagement] Upload session response: #{response.body}"
    response['id']
  end

  def upload_file_to_session(session_id, file_path)
    file_data = File.binread(file_path)
    response = HTTParty.post(
      "#{api_base_path}/#{WHATSAPP_API_VERSION}/#{session_id}",
      headers: {
        'Authorization' => "OAuth #{api_key}",
        'file_offset' => '0',
        'Content-Type' => 'application/octet-stream'
      },
      body: file_data
    )
    Rails.logger.info "[WhatsApp TemplateManagement] Upload file response: #{response.body}"
    response['h']
  end

  def build_create_request_body(params)
    body = {
      name: params[:name],
      category: params[:category]&.upcase || 'UTILITY',
      language: params[:language] || 'en',
      components: build_components(params)
    }
    body[:parameter_format] = params[:parameter_format] if params[:parameter_format].present?
    body
  end

  def build_update_request_body(params)
    body = {}
    body[:category] = params[:category].upcase if params[:category].present?
    body[:components] = build_components(params) if params[:body].present?
    body
  end

  def build_components(params)
    components = []
    components << build_header_component(params[:header]) if params[:header].present?
    components << { type: 'BODY', text: params[:body] } if params[:body].present?
    components << { type: 'FOOTER', text: params[:footer] } if params[:footer].present?
    components << build_buttons_component(params[:buttons]) if params[:buttons].present?
    components.compact
  end

  def build_header_component(header)
    return nil if header[:type].blank? || header[:type].upcase == 'NONE'

    case header[:type].upcase
    when 'TEXT'
      { type: 'HEADER', format: 'TEXT', text: header[:text] }
    when 'IMAGE', 'VIDEO', 'DOCUMENT'
      component = { type: 'HEADER', format: header[:type].upcase }
      component[:example] = { header_handle: [header[:media_handle]] } if header[:media_handle].present?
      component
    end
  end

  def build_buttons_component(buttons)
    {
      type: 'BUTTONS',
      buttons: buttons.map { |btn| build_single_button(btn) }
    }
  end

  def build_single_button(btn)
    case btn[:type]&.upcase
    when 'QUICK_REPLY'
      { type: 'QUICK_REPLY', text: btn[:text] }
    when 'URL'
      { type: 'URL', text: btn[:text], url: btn[:url] }
    when 'PHONE_NUMBER'
      { type: 'PHONE_NUMBER', text: btn[:text], phone_number: btn[:phone_number] }
    else
      { type: 'QUICK_REPLY', text: btn[:text] }
    end
  end

  def fetch_all_templates(url)
    response = HTTParty.get(url)
    return [] unless response.success?

    next_url = response.dig('paging', 'next')
    templates = response['data'] || []
    templates += fetch_all_templates(next_url) if next_url.present?
    templates
  end

  def sync_templates_async
    Channels::Whatsapp::TemplatesSyncJob.perform_later(@whatsapp_channel)
  end

  def business_account_path
    "#{api_base_path}/#{WHATSAPP_API_VERSION}/#{@whatsapp_channel.provider_config['business_account_id']}"
  end

  def api_key
    @whatsapp_channel.provider_config['api_key']
  end

  def api_headers
    {
      'Authorization' => "Bearer #{api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def api_base_path
    ENV.fetch('WHATSAPP_CLOUD_BASE_URL', 'https://graph.facebook.com')
  end
end
