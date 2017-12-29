require_relative '../support/env.rb'

require 'faraday'
require 'faraday_middleware'

module Services
  class Schedule
    class ScheduleClient
      def initialize(url)
        @conn = Faraday.new(url) do |f|
          f.request(:json) 
          f.response(:json, :content_type => /\bjson$/)
          f.adapter(Faraday.default_adapter)
        end
      end

      def schedule(doc)
        resp = @conn.post('/actions', { name: 'document-add', payload: doc })
        p resp
      end
    end
    
    def self.send_document(doc)
      if Env.fetch('SERVICES_SCHEDULE_SHOULD_SEND', true)
        url = Env.fetch('SERVICES_SCHEDULE_SERVICE_URL', 'http://localhost:9292')
        cl = ScheduleClient.new(url)
        cl.schedule(doc)
      end
    end
  end
end
