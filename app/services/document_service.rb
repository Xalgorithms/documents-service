require 'radish/documents/core'
require 'xa/ubl/invoice'

class DocumentService
  extend Radish::Documents::Core

  class Parser
    include XA::UBL::Invoice
  end

  def self.make_envelope(content)
    env = {}.tap do |o|
      sic = get(content, 'parties.supplier.industry_code', {})
      cic = get(content, 'parties.customer.industry_code', {})

      v = get(sic, 'value', nil)
      if get(sic, 'list.id', nil) == 'ISIC' && v
        o[:industry] = { supplier: v }
      end
      v = cic.fetch('value', nil)
      if get(cic, 'list.id', nil) == 'ISIC' && v
        o[:industry] = o[:industry].merge(customer: v)
      end
    end
  end
  
  def self.created(id)
    dm = Document.find(id)
    if dm
      Parser.new.parse(dm.src) do |content|
        # extract the envelope
        content = content.with_indifferent_access

        dm.update_attributes(content: content, envelope: make_envelope(content))
      end

      QueueService.document_created(id)
    end
  end
end
