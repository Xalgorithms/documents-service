class Document
  include Mongoid::Document

  field :public_id, type: String
  field :src, type: String
end
