require 'grape'
require 'multi_json'
require_relative '../../services/actions'

module APIs
  module V1
    class Actions < Grape::API
      version 'v1', using: :path
      format :json

      resource :actions do
        post do
          o = MultiJson.decode(request.body.read)
          err = Services::Actions.invoke(:global, o['name'], o['payload'])
          if err
            error!(err.slice(:status, :reason), 404)
          else
            { status: :ok }
          end
        end
      end
    end
  end
end
