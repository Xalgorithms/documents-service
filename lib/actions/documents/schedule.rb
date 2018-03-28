require_relative '../../clients/schedule'
require_relative '../../../services/documents'

module Actions
  module Documents
    class Schedule
      def self.invoke(o)
        puts "# invoke Schedule"
        cl = Clients::Schedule.new
        cl.document_add(Services::Documents.get(o[:document_id], 'json'))
      end
    end
  end
end
