module Api
  module V1
    class EventsController < ApplicationController
      def create
        @events ||= {
          'add' => {
            klass: Events::Add,
            args: [:document],
          }
        }

        k = params.fetch(:name, nil)
        o = @events.fetch(k, nil) if k
        if o
          begin
            payload = params.require(:payload).permit(@events[k][:args])
            em = @events[k][:klass].create(payload)
            render(json: EventSerializer.one(em))
          rescue ActionController::ParameterMissing => e
            head(:bad_request)
          end
        else
          head(:bad_request)
        end
      end

      def show
        em = Events::Event.where(public_id: params['id']).first
        render(json: EventSerializer.one(em))
      end

      private

      def make
        k = params.keys.drop_while { |k| !@events.key?(k) }.first
        args = params.require(k).permit(*@events[k][:args])
        @events[k][:klass].create(args)
      end
    end
  end
end
