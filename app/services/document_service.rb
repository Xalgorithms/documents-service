require 'xa/ubl/invoice'

class DocumentService
  class Parser
    include XA::UBL::Invoice
  end
  
  def self.created(id)
    dm = Document.find(id)
    if dm
      Parser.new.parse(dm.src) do |content|
        dm.update_attributes(content: content)
      end

      QueueService.document_created(id)
    end
  end
end
