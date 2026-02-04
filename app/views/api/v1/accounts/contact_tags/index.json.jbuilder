json.payload do
  json.array! @contact_tags do |contact_tag|
    json.id contact_tag.id
    json.title contact_tag.title
    json.description contact_tag.description
    json.color contact_tag.color
    json.show_on_sidebar contact_tag.show_on_sidebar
  end
end
