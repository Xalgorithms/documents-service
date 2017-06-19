class EventService
  def self.created(id)
    @events ||= {
      'add' => method(:created_add)
    }

    em = Events::Event.find(id)
    if em
      fn = @events.fetch(em.class.name.demodulize.downcase)
      fn.call(em) if fn
    end
  end

  private

  def self.created_add(em)
    Document.create(src: em.document)
  end
end
