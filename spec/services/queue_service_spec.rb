describe QueueService do
  after(:all) do
    Document.destroy_all
  end
  
  it 'should send document_created messages over the publisher' do
    rand_times.each do
      pub = double(:publisher)
      sent = nil
      expect(pub).to receive(:publish) do |n, o|
        expect(n).to eql('')
        sent = o
      end
        
      expect(XA::Messages::DirectPublisher).to receive(:for).with('xa.rules.requests').and_yield(pub)
      

      # document > document_service > queue_service should be auto-triggered on document creation
      QueueService.force_publish_on
      dm = Document.create
      QueueService.force_publish_off

      ex = {
        origin: 'documents',
        name: 'document.created',
        details: DocumentSerializer.one(dm),
      }
      expect(sent).to eql(ex)
    end
  end
end
