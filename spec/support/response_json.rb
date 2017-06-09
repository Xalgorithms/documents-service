require 'multi_json'

module ResponseJson
  def response_json
    MultiJson.decode(response.body)
  end

  def encode_decode(o)
    MultiJson.decode(MultiJson.encode(o))
  end
end

RSpec.configure do |config|
  config.include(ResponseJson)
end
