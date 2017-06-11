class Document
  include Mongoid::Document

  field :public_id, type: String
  field :src, type: String
  field :content, type: Hash

  after_create do |m|
    DocumentService.created(m._id.to_s)
  end
end
