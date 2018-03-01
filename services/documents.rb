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
      puts "# got document (#{id})"
      id
    end
  end
end
