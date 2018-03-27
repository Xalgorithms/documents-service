require_relative './google_storage'
require_relative './local_temp_storage'
require_relative '../lib/clients/functions'

require 'multi_json'
require 'uuid'
require 'xa/ubl/invoice'

# By default, this service will simply store the incoming UBL in a
# tempfile and send back the path of that file. In order to test
# against GCLOUD STORAGE, you will need to run the service as:
#
# $ GOOGLE_APPLICATION_CREDENTIALS=<path to creds json> GCLOUD_PROJECT_ID=<project_id> GCLOUD_USE_STORAGE=true bundle exec rackup
module Services
  class Documents
    class Parser
      include XA::UBL::Invoice
    end
    
    def initialize
      @locations = {
        'google-storage' => GoogleStorage.new,
        'local-tmp'      => LocalTempStorage.new,
      }
      @functions = Clients::Functions.new
    end

    def self.create(token, f)
      @service ||= Documents.new
      @service.create(token, f)
    end

    def self.get(id, fmt)
      @service ||= Documents.new
      @service.get(id, fmt)
    end
    
    def create(token, f)
      id = UUID.generate

      if @functions.document(token, "/documents/#{id}")
        with_location do |loc|
          loc.store(id, f)
        end
      end
      
      id
    end

    def get(id, fmt)
      with_location do |loc|
        content = loc.get(id)
        fmt == 'json' ? MultiJson.encode(Parser.new.parse(content)) : content.read
      end
    end

    private

    def with_location
      k = ENV.fetch('DOCUMENT_STORAGE_LOCATION', 'local-tmp')
      if @locations.key?(k)
        yield(@locations[k])
      else
        puts "! invalid storage location (key=#{k})"
      end
    end
  end
end
