class EventService
  def self.created(em)
    @events ||= {
      'add' => method(:created_add)
    }

    fn = @events.fetch(em.class.name.demodulize.downcase)
    fn.call(em) if fn
  end

  private

  def self.created_add(em)
    Document.create(src: em.document)
  end
end
