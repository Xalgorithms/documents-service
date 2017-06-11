class QueueService
  def self.document_created(id)
    dm = Document.find(id)
    XA::Messages::DirectPublisher.for('sneakers') do |pub|
      pub.publish('director', origin: 'documents', name: 'document.created', details: { id: dm.public_id })
    end unless Rails.env.test?
  end
end
