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

  def some_countries
    countries = rand_array_of_countries(40).select { |c| c.subdivisions.any? }
    rand_times.each do
      sc = rand_one(countries)
      cc = rand_one(countries)
      yield(sc, cc)
    end
  end

  def set_countries(sc, cc, skv, ckv)
    sup = set({}, skv[0], sc.send(skv[1]))
    cus = set({}, ckv[0], cc.send(ckv[1]))

    { 'parties' => { 'supplier' => sup, 'customer' => cus } }
  end
  
  it 'should configure the envelope location country code from physical location and postal address' do
    some_countries do |sc, cc|
      ex = {
        locations: {
          supplier: {
            country: sc.alpha2,
          },
          customer: {
            country: cc.alpha2,
          },
        }
      }

      keys = [
        ['location.address.country.code.value', :alpha2],
        ['location.address.country.name', :alpha2],
        ['location.address.country.name', :alpha3],
        ['location.address.country.name', :name],
        ['address.country.code.value', :alpha2],
        ['address.country.name', :alpha2],
        ['address.country.name', :alpha3],
        ['address.country.name', :name],
      ]

      keys.each do
        content = set_countries(sc, cc, rand_one(keys), rand_one(keys))
        expect(DocumentService.make_envelope(content)).to eql(ex)
      end
    end
  end
  
  def set_subentities(sse, cse, skv, ckv)
    sup = set({}, skv[0], skv[1].call(sse))
    cus = set({}, ckv[0], ckv[1].call(cse))

    { 'parties' => { 'supplier' => sup, 'customer' => cus } }
  end
  
  it 'should configure the envelope location subentity code from physical location and postal address' do
    some_countries do |sc, cc|
      ssek = rand_one(sc.subdivisions.keys)
      sse = { country: sc, subentity: sc.subdivisions[ssek], code: ssek }
      csek = rand_one(cc.subdivisions.keys)
      cse = { country: cc, subentity: cc.subdivisions[csek], code: csek }
      ex = {
        locations: {
          supplier: {
            subentity: ssek,
          },
          customer: {
            subentity: csek,
          },
        }
      }

      keys = [
        ['location.address.subentity.code.value', lambda { |o| "#{o[:country].alpha2}-#{o[:code]}" }],
        ['location.address.subentity.name', lambda { |o| "#{o[:country].alpha2}-#{o[:code]}" }],
        ['address.subentity.code.value', lambda { |o| "#{o[:country].alpha2}-#{o[:code]}" }],
        ['address.subentity.name', lambda { |o| "#{o[:country].alpha2}-#{o[:code]}" }],
      ]

      keys.each do
        content = set_subentities(sse, cse, rand_one(keys), rand_one(keys))
        expect(DocumentService.make_envelope(content)).to eql(ex)
      end
    end
  end

  it 'should configure the envelope location subentity code from physical location and postal address, by name if country is set' do
    some_countries do |sc, cc|
      ssek = rand_one(sc.subdivisions.keys)
      sse = sc.subdivisions[ssek]
      csek = rand_one(cc.subdivisions.keys)
      cse = cc.subdivisions[csek]
      ex = {
        locations: {
          supplier: {
            country: sc.alpha2,
            subentity: ssek,
          },
          customer: {
            country: cc.alpha2,
            subentity: csek,
          },
        }
      }
      
      sup = {
        address: {
          country: { code: { value: sc.alpha2 } },
          subentity: { name: sse.name },
        }
      }
      cus = {
        address: {
          country: { code: { value: cc.alpha2 } },
          subentity: { name: cse.name },
        }
      }
      
      keys = [
        ['location.address.subentity.name', lambda { |o| o[:subentity][:name] } ],
        ['address.subentity.name', lambda { |o| o[:subentity][:name] } ],
      ]

      content = {
        parties: {
          supplier: {
            location: sup
          },
          customer: {
            location: cus
          },
        },
      }.with_indifferent_access

      expect(DocumentService.make_envelope(content)).to eql(ex)
      
      content = {
        parties: {
          supplier: sup,
          customer: cus,
        },
      }.with_indifferent_access
      
      expect(DocumentService.make_envelope(content)).to eql(ex)
    end
  end
end
