require 'faraday'
require 'faraday_middleware'
require 'multi_json'

class Functions
  def initialize()
    url = ENV.fetch('FIREBASE_FUNCTION_URL', nil)
    if url
      @conn = Faraday.new(url) do |f|
        f.request(:url_encoded)
        f.request(:json)
        f.response(:json, :content_type => /\bjson$/)
        f.adapter(Faraday.default_adapter)
      end
    else
      puts '! no url specified for functions'
    end
  end

  def document(token, url)
    puts "> POST /document"
    if @conn
      resp = @conn.post('/document', { token: token, url: url })
      puts "< #{resp.status}"
      if resp.success?
        true
      else
        puts "! failed to send document (#{resp.body})"
        false
      end
    else
      true
    end
  end
end
