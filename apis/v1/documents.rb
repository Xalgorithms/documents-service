require 'grape'
require_relative '../../services/documents'

module APIs
  module V1
    class Documents < Grape::API
      format :json
      version 'v1', using: :path

      VALID_FORMATS = ['ubl', 'json']

      resource :documents do
        get ':id.:format' do
          fmt = params[:format]
          if VALID_FORMATS.include?(fmt)
            content = Services::Documents.get(params[:id], fmt)
            { status: :ok, content: content }
          else
            error!({ status: :invalid_format, reason: "format not in expected list (format=#{fmt}; list=#{VALID_FORMATS.join(', ')})" }, 404)
          end
        end

        get ':id' do
          content = Services::Documents.get(params[:id], 'json')
          { status: :ok, content: content }
        end

        post do
          f = params[:content][:tempfile]
          id = Services::Documents.create(headers['X-Lichen-Token'], f)
          { id: id }
        end

        route_param :id do
          resource :actions do
            post do
              o = MultiJson.decode(request.body.read)
              err = Services::Actions.invoke(:documents, o['name'], o.fetch('payload', {}).merge(document_id: params[:id]))
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
  end
end
