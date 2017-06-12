class DocumentSerializer < Serializer
  def self.one(m, context=nil)
    {
      id: m.public_id,
      url: Rails.application.routes.url_helpers.api_v1_document_path(m.public_id)
    }.tap do |o|
      o[:content] = m.content if :with_content == context
    end
  end
end
