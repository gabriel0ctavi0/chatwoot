class Contacts::BulkAssignTagsService
  def initialize(account:, contact_ids:, tags:)
    @account = account
    @contact_ids = Array(contact_ids)
    @tags = Array(tags).compact_blank
  end

  def perform
    return { success: true, updated_contact_ids: [] } if @contact_ids.blank? || @tags.blank?

    contacts = @account.contacts.where(id: @contact_ids)

    contacts.find_each do |contact|
      contact.add_contact_tags(@tags)
    end

    { success: true, updated_contact_ids: contacts.pluck(:id) }
  end
end
