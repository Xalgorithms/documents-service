require 'grape'
require_relative '../../services/documents'

module Documents
  class APIv1 < Grape::API
    format :json

    params do
      requires :id, type: String
    end
    route_param :id do
      get do
        Services::Documents.find(params[:id])
      end
    end
    
    post do
      f = params[:content][:tempfile]
      id = Services::Documents.create(f)
      { id: id }
    end
  end
end
