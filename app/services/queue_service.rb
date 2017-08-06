class QueueService
  @@force_publish = false
  
  def self.force_publish_on
    @@force_publish = true
  end

  def self.force_publish_off
    @@force_publish = false
  end
  
  def self.document_created(id)
    dm = Document.find(id)
    XA::Messages::DirectPublisher.for('xa.rules.requests') do |pub|
      o = DocumentSerializer.one(dm)
      pub.publish('', origin: 'documents', name: 'document.created', details: o)
    end unless Rails.env.test? && !@@force_publish
  end
end
