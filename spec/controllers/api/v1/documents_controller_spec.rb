require 'rails_helper'

describe Api::V1::DocumentsController, type: :controller do
  include Randomness
  include ResponseJson

  after(:all) do
    Document.destroy_all
  end

  it 'should provide the document content in GET' do
    rand_array_of_documents.each do |doc|
      dm = create(:document, content: doc)

      get(:show, params: { id: dm.public_id })

      expect(response).to be_success
      expect(response_json).to eql(doc.with_indifferent_access)
    end
  end

  it 'should yield NOT FOUND for non-existant documents' do
    rand_array_of_uuids.each do |id|
      get(:show, params: { id: id })

      expect(response).to_not be_success
      expect(response).to have_http_status(:not_found)
    end
  end
end
