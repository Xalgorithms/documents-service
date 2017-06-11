require 'rails_helper'

describe Document, type: :model do
  include Randomness
  
  after(:all) do
    Document.destroy_all
  end

  it 'should trigger DocumentService on creation' do
    rand_times.each do
      service_id = nil
      expect(DocumentService).to receive(:created) do |id|
        service_id = id
      end
      dm = Document.create(src: '')

      expect(service_id).to eql(dm._id.to_s)
    end
  end
end
