module Lavigne
  module Cucumber
    class BaseFormatter
      attr_reader :writer

      def initialize(config)
        io = File.open(config.out_stream, 'wb')
        @writer = ::Lavigne.datafile_writer(io)
        ::Lavigne.write_headers @writer
        at_exit do
          @writer.close unless @writer.writer.closed?
        end
      end

    end
  end
end
