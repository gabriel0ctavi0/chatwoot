class Contacts::FilterService < FilterService
  ATTRIBUTE_MODEL = 'contact_attribute'.freeze

  def initialize(account, user, params)
    @account = account
    # TODO: Change the order of arguments in FilterService maybe?
    # account, user, params makes more sense
    super(params, user)
  end

  def perform
    validate_query_operator
    @contacts = query_builder(@filters['contacts'])

    {
      contacts: @contacts,
      count: @contacts.count
    }
  end

  def filter_values(query_hash)
    attribute_key = query_hash['attribute_key']
    values = query_hash['values']

    return tag_filter_values(values) if attribute_key.in?(%w[labels contact_tags])

    current_val = values.is_a?(Array) ? values[0] : values
    if attribute_key == 'phone_number'
      "+#{current_val&.delete('+')}"
    elsif attribute_key == 'country_code'
      current_val.to_s.downcase
    else
      current_val.is_a?(String) ? current_val.downcase : current_val
    end
  end

  def tag_filter_values(values)
    Array(values).map { |v| v.to_s.strip.downcase.presence }.compact.uniq
  end

  def base_relation
    @account.contacts.resolved_contacts(use_crm_v2: @account.feature_enabled?('crm_v2'))
  end

  def filter_config
    {
      entity: 'Contact',
      table_name: 'contacts'
    }
  end

  private

  def equals_to_filter_string(filter_operator, current_index)
    return "= :value_#{current_index}" if filter_operator == 'equal_to'

    "!= :value_#{current_index}"
  end
end
