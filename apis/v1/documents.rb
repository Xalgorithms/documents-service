require 'grape'
require_relative '../../services/documents'

module Documents
  class APIv1 < Grape::API
    format :json

    # get do
    # end

    post do
      f = params[:content][:tempfile]
      Services::Documents.create(f)
      { }
    end
  end
end
