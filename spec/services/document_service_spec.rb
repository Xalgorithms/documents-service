require 'radish/documents/core'
require 'xa/ubl/invoice'

describe DocumentService do
  include Radish::Documents::Core
  
  after(:all) do
    Document.destroy_all
  end

  class Parser
    include XA::UBL::Invoice
  end

  def with_files(files)
    pr = Parser.new
    
    files.each do |fn|
      src = IO.read(fn)
      pr.parse(src) do |content|
        yield(src, content.with_indifferent_access)
      end
    end
  end
  
  it 'should parse src when created' do
    files = [
      'spec/files/1.xml',
      'spec/files/2.xml',
    ]
    with_files(files) do |src, content|
      queue_doc_id = nil
      expect(QueueService).to receive(:document_created) do |id|
        queue_doc_id = id
      end
      expect(DocumentService).to receive(:make_envelope).and_return({})
      dm = Document.create(src: src)
      
      expect(queue_doc_id).to eql(dm._id.to_s)
      # create automatically calls service
      dm.reload
      expect(dm.content).to eql(content.with_indifferent_access)
    end
  end

  it 'should configure the envelope industry codes on creation' do
    files = [
      'spec/files/1.xml',
      'spec/files/gas_tax_example.xml',
    ]
    with_files(files) do |src, content|
      ex = {
        'industry' => {
          'supplier' => get(content, 'parties.supplier.industry_code.value'),
          'customer' => get(content, 'parties.customer.industry_code.value'),
        },
      }

      expect(DocumentService).to receive(:make_envelope).and_return(ex)
      dm = Document.create(src: src)

      dm.reload
      expect(dm.envelope).to eql(ex)
    end
  end
end
