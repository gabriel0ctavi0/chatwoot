json.payload do
  json.array! @contacts do |contact|
    json.id contact.id
    json.name contact.name
    json.email contact.email
    json.phone_number contact.phone_number
    json.thumbnail contact.avatar_url
    json.funnel_id contact.funnel_id
    json.funnel_stage contact.funnel_stage
    json.last_activity_at contact.last_activity_at.to_i if contact.last_activity_at.present?
    json.updated_at contact.updated_at.to_i
    json.company do
      if contact.company.present?
        json.id contact.company.id
        json.name contact.company.name
      end
    end
  end
end
