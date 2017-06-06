module Lavigne
  module Cucumber
    class Formatter
      attr_reader :instance

      def initialize(config)
        @instance = Lavigne.formatter.new(config)
      end

      def respond_to?(meth)
        instance.respond_to?(meth)
      end

      def method_missing(meth, *args)
        instance.send(meth, *args)
      end
    end
  end
end
