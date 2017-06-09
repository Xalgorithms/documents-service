require 'rails_helper'

describe Api::V1::EventsController, type: :controller do
  include Randomness
  include ResponseJson

  after(:all) do
    Events::Event.destroy_all
  end

  it 'should refuse unknown events' do
    rand_array_of_words.each do |n|
      post(:create, params: { name: n, payload: {} })

      expect(response).to_not be_success
      expect(response).to have_http_status(:bad_request)
    end
  end

  it 'should accept add events' do
    rand_array_of_documents.each do |doc|
      count = Document.count

      created_public_id = nil
      expect(EventService).to receive(:created) do |em|
        created_public_id = em.public_id
      end
      
      post(:create, params: { name: 'add', payload: { document: MultiJson.encode(doc) } })
      
      expect(response).to be_success
      
      o = response_json
      expect(o).to have_key('id')
      em = Events::Add.where(public_id: o['id']).first

      expect(em).to_not be_nil
      expect(em.document).to eql(MultiJson.encode(doc))
      expect(o).to eql(EventSerializer.one(em).with_indifferent_access)

      expect(created_public_id).to eql(em.public_id)

      # see if we can get it
      get(:show, params: { id: em.public_id })

      expect(response).to be_success
      expect(o).to eql(EventSerializer.one(em).with_indifferent_access)
    end
  end

  it 'should refuse add events with bad payload' do
    rand_times.each do |n|
      post(:create, params: { name: 'add', payload: { } })

      expect(response).to_not be_success
      expect(response).to have_http_status(:bad_request)
    end
  end
end
