require 'grape'
require_relative '../../services/documents'

module Documents
  class APIv1 < Grape::API
    format :json

    VALID_FORMATS = ['ubl', 'json']

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
  end
end
