module Api
  module V1
    class DocumentsController < ApplicationController
      def show
        dm = Document.where(public_id: params[:id]).first
        if dm
          render(json: dm.content)
        else
          head(:not_found)
        end
      end
    end
  end
end
