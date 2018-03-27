module Actions
  module Documents
    class Schedule
      def self.invoke(o)
        puts "# invoke Schedule"
        p o
      end
    end
  end
end
