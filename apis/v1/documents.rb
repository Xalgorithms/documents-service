require 'grape'
require_relative '../../services/documents'

module Documents
  class APIv1 < Grape::API
    format :json

    # get do
    # end

    post do
      f = params[:content][:tempfile]
      id = Services::Documents.create(f)
      { id: id }
    end
  end
end
