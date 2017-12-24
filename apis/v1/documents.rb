require 'grape'

module Documents
  class APIv1 < Grape::API
    format :json

    # get do
    # end

    post do
      content = params[:content][:tempfile].read

      { }
    end
  end
end
