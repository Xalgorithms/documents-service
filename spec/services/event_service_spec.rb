require 'rails_helper'

describe EventService do
  include Randomness

  after(:all) do
    Events::Event.destroy_all
    Document.destroy_all
  end

  it 'should add Documents when Events::Add is created' do
    rand_array_of_documents.each do |doc|
      encoded = MultiJson.encode(doc)
      count = Document.count

      em = Events::Add.create(document: encoded)
      # creation automatically calls the service

      expect(Document.count).to eql(count + 1)
      dm = Document.last
      expect(dm.src).to eql(encoded)
    end
  end
end
