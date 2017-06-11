require 'xa/ubl/invoice'

class DocumentService
  class Parser
    include XA::UBL::Invoice
  end
  
  def self.created(id)
    dm = Document.find(id)
    Parser.new.parse(dm.src) do |content|
      dm.update_attributes(content: content)
    end
  end
end
