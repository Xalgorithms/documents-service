require 'faraday'
require 'faraday_middleware'
require 'multi_json'

module Clients
  class Schedule
    def initialize()
      url = ENV.fetch('XADF_SCHEDULE_URL', nil)
      if url
        @conn = Faraday.new(url) do |f|
          f.request(:json)
          f.response(:json, :content_type => /\bjson$/)
          f.adapter(Faraday.default_adapter)
        end
      else
        puts '! no url specified for schedule'
      end
    end

    def document_add(payload)
      puts '> POST (schedule) /actions'
      res = @conn.post('/actions', name: 'document-add', payload: MultiJson.decode(payload))
      puts "< #{res.status}"
      res.success? ? nil : { reason: 'api_failure', message: res.body }
    end
  end
end
