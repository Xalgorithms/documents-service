describe DocumentSerializer do
  include Randomness

  after(:all) do
    Document.destroy_all
  end
  
  it 'should serialize basic properties of a document' do
    rand_array_of_models(:document, content: rand_document).each do |m|
      ex = {
        id: m.public_id,
        url: Rails.application.routes.url_helpers.api_v1_document_path(m.public_id)
      }
      expect(DocumentSerializer.one(m)).to eql(ex)

      ex = ex.merge(content: m.content)
      expect(DocumentSerializer.one(m, :with_content)).to eql(ex)
    end
  end
end
