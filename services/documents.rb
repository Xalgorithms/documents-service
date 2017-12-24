require 'xa/ubl/invoice'

module Services
  class Documents
    class Loader
      include XA::UBL::Invoice
    end
    
    def self.create(f)
      # parse
      Loader.new.parse(f.read) do |doc|
        p doc
      end
    end
  end
end
