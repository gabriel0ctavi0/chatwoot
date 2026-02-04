class DataImport::ContactManager
  def initialize(account)
    @account = account
  end

  def build_contact(params)
    return invalid_contact_for_missing_required(params) if required_attributes_missing?(params)

    contact = find_or_initialize_contact(params)
    update_contact_attributes(params, contact)
    contact
  end

  def find_or_initialize_contact(params)
    contact = find_existing_contact(params)
    contact_params = params.slice(:email, :identifier, :phone_number)
    contact_params[:phone_number] = format_phone_number(contact_params[:phone_number]) if contact_params[:phone_number].present?
    contact ||= @account.contacts.new(contact_params)
    contact
  end

  def find_existing_contact(params)
    contact = find_contact_by_identifier(params)
    contact ||= find_contact_by_email(params)
    contact ||= find_contact_by_phone_number(params)

    update_contact_with_merged_attributes(params, contact) if contact.present? && contact.valid?
    contact
  end

  def find_contact_by_identifier(params)
    return unless params[:identifier]

    @account.contacts.find_by(identifier: params[:identifier])
  end

  def find_contact_by_email(params)
    return unless params[:email]

    @account.contacts.from_email(params[:email])
  end

  def find_contact_by_phone_number(params)
    return unless params[:phone_number]

    @account.contacts.find_by(phone_number: format_phone_number(params[:phone_number]))
  end

  def format_phone_number(phone_number)
    phone_number.start_with?('+') ? phone_number : "+#{phone_number}"
  end

  def update_contact_with_merged_attributes(params, contact)
    contact.identifier = params[:identifier] if params[:identifier].present?
    contact.email = params[:email] if params[:email].present?
    contact.phone_number = format_phone_number(params[:phone_number]) if params[:phone_number].present?
    update_contact_attributes(params, contact)
    contact.save
  end

  private

  def required_attributes_missing?(params)
    name_present = params[:name].to_s.strip.present?
    name_present ||= (params[:first_name].to_s.strip.present? || params[:last_name].to_s.strip.present?)
    phone_present = params[:phone_number].to_s.strip.present?
    !name_present || !phone_present
  end

  def invalid_contact_for_missing_required(params)
    contact = @account.contacts.new
    contact.errors.add(:base, I18n.t('errors.contacts.import.name_and_phone_required'))
    contact
  end

  def sanitize_name_string(str)
    return '' if str.blank?

    s = str.to_s
    utf8 = s.force_encoding('UTF-8')
    return s.strip if utf8.valid_encoding?

    s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').strip
  end

  def update_contact_attributes(params, contact)
    name_value = sanitize_name_string(params[:name]).presence
    name_value ||= [params[:first_name], params[:last_name]].map { |v| sanitize_name_string(v).presence }.compact.join(' ') if params[:first_name].present? || params[:last_name].present?
    contact.name = name_value if name_value.present?
    contact.additional_attributes ||= {}
    contact.additional_attributes[:city] = params[:city].to_s.strip.presence if params[:city].present?
    contact.additional_attributes[:country] = params[:country].to_s.strip.presence if params[:country].present?
    company_value = (params[:company_name].presence || params[:company].presence).to_s.strip.presence
    contact.additional_attributes[:company_name] = company_value if company_value.present?
    custom_keys = params.keys - %i[identifier email name first_name last_name phone_number city country company_name company tag label]
    custom_params = params.slice(*custom_keys)
    contact.assign_attributes(custom_attributes: contact.custom_attributes.merge(custom_params)) if custom_params.present?
  end
end
