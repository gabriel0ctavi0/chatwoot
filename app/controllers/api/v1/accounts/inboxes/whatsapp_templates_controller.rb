class Api::V1::Accounts::Inboxes::WhatsappTemplatesController < Api::V1::Accounts::BaseController
  before_action :fetch_inbox
  before_action :validate_whatsapp_channel

  def index
    service = Whatsapp::TemplateManagementService.new(@inbox.channel)
    result = service.list_templates(status: params[:status])

    if result[:success]
      render json: { templates: result[:templates] }
    else
      render json: { error: result[:error] }, status: :internal_server_error
    end
  end

  def create
    service = Whatsapp::TemplateManagementService.new(@inbox.channel)
    result = service.create_template(template_params)

    if result[:success]
      render json: { template: result.slice(:template_id, :template_name, :status) }, status: :created
    else
      render_error_response(result)
    end
  end

  def update
    service = Whatsapp::TemplateManagementService.new(@inbox.channel)
    result = service.update_template(params[:id], template_params)

    if result[:success]
      render json: { success: true }
    else
      render_error_response(result)
    end
  end

  def destroy
    service = Whatsapp::TemplateManagementService.new(@inbox.channel)
    result = service.delete_template(params[:name], template_id: params[:id])

    if result[:success]
      render json: { success: true }
    else
      render_error_response(result)
    end
  end

  def upload_media
    file = params[:file]
    return render json: { error: 'No file provided' }, status: :bad_request if file.blank?

    blob = ActiveStorage::Blob.create_and_upload!(
      io: file.tempfile,
      filename: file.original_filename,
      content_type: file.content_type
    )

    url = rails_blob_url(blob, host: ENV.fetch('FRONTEND_URL', request.base_url))
    render json: { url: url }
  end

  private

  def fetch_inbox
    @inbox = Current.account.inboxes.find(params[:inbox_id])
    authorize @inbox, :show?
  end

  def validate_whatsapp_channel
    return if @inbox.whatsapp? || @inbox.twilio_whatsapp?

    render json: { error: 'Template operations are only available for WhatsApp channels' }, status: :bad_request
  end

  def template_params
    params.require(:template).permit(:name, :category, :language, :body, :footer, :parameter_format,
                                     header: [:type, :text, :media_url],
                                     buttons: [:type, :text, :url, :phone_number])
  end

  def render_error_response(result)
    error_details = parse_whatsapp_error(result[:response_body])
    error_message = error_details[:user_message] || result[:error]

    render json: { error: error_message, details: error_details[:technical_details] }, status: :unprocessable_entity
  end

  def parse_whatsapp_error(response_body)
    return { user_message: nil, technical_details: nil } if response_body.blank?

    error_data = JSON.parse(response_body)
    whatsapp_error = error_data['error'] || {}

    {
      user_message: whatsapp_error['error_user_msg'] || whatsapp_error['message'],
      technical_details: {
        code: whatsapp_error['code'],
        subcode: whatsapp_error['error_subcode'],
        type: whatsapp_error['type']
      }.compact
    }
  rescue JSON::ParserError
    { user_message: nil, technical_details: response_body }
  end
end
