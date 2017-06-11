require 'xa/ubl/invoice'

describe DocumentService do
  FILES = [
    'spec/files/1.xml',
    'spec/files/2.xml',
  ]

  after(:all) do
    Document.destroy_all
  end

  class Parser
    include XA::UBL::Invoice
  end
  
  
  it 'should parse src when created' do
    pr = Parser.new
    
    FILES.each do |fn|
      src = IO.read(fn)
      pr.parse(src) do |content|
        dm = Document.create(src: src)

        # create automatically calls service
        dm.reload
        expect(dm.content).to eql(content.with_indifferent_access)
      end
    end
  end
end
