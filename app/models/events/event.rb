module Events
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps

    field :public_id, type: String
    
    def initialize(*args)
      super(*args)
      self.public_id ||= UUID.generate
    end

    after_create do |e|
      EventService.created(e._id)
    end
  end
end
