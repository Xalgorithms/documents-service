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
      cl = Arango::Connection.new
      cl.databases['lichen'].collections['documents'].add(id: id, content: doc)
      id
    end
  end
end
