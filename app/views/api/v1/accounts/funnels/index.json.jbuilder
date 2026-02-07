json.payload do
  json.array! @funnels do |funnel|
    json.id funnel.id
    json.name funnel.name
  end
end
