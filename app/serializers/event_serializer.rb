class EventSerializer < Serializer
  def self.one(m)
    {
      id: m.public_id,
      name: m.class.name.demodulize.downcase,
      url: Rails.application.routes.url_helpers.api_v1_event_path(m.public_id)
    }
  end
end
