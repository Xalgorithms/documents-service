class Document
  include Mongoid::Document

  field :public_id, type: String
  field :src, type: String
  field :content, type: Hash
  field :envelope, type: Hash

  def initialize(*args)
    super(*args)
    self.public_id ||= UUID.generate
  end  
  
  after_create do |m|
    DocumentService.created(m._id.to_s)
  end
end
