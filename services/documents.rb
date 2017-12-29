require_relative './schedule'

require 'arango/connection'
require 'xa/ubl/invoice'
require 'uuid'

module Services
  class Documents
    class Loader
      include XA::UBL::Invoice
    end
    
    def self.create(f)
      doc = Loader.new.parse(f.read)
      id = UUID.generate
      collection.add(id: id, content: doc)
      Schedule.send_document(doc)
      id
    end

    def self.find(id)
      doc = collection.by_example(id: id).first
      doc.content.fetch('content', nil) if doc
    end

    private

    def self.collection
      cl = Arango::Connection.new
      cl.databases['lichen'].collections['documents']
    end
  end
end
