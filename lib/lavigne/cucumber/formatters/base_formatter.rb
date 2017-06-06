module Lavigne
  module Cucumber
    class BaseFormatter
      attr_reader :writer

      def initialize(config)
        io = File.open(config.out_stream, 'wb')
        @headers_needed = true
        @writer = ::Lavigne.datafile_writer(io)
        at_exit do
          @writer.close unless @writer.writer.closed?
        end
      end

      # Implementation adapted from the json formatter
      def embed(src, mime_type, _label)
        if File.file?(src)
          content = File.open(src, 'rb', &:read)
          data = encode64(content)
        else
          if mime_type =~ /;base64$/
            mime_type = mime_type[0..-8]
            data = src
          else
            data = encode64(src)
          end
        end
        test_step_embeddings << { 'mime_type' => mime_type, 'data' => data }
      end

      def puts(message)
        test_step_output << message
      end

      def current_feature
        @feature_hash ||= {}
      end

      def feature_elements
        @feature_hash['elements'] ||= []
      end

      def steps
        @element_hash['steps'] ||= []
      end

      def before_hooks
        @element_hash['before'] ||= []
      end

      def after_hooks
        @element_hash['after'] ||= []
      end

      def around_hooks
        @element_hash['around'] ||= []
      end

      def after_step_hooks
        @step_hash['after'] ||= []
      end

      def test_step_output
        @step_or_hook_hash['output'] ||= []
      end

      def test_step_embeddings
        @step_or_hook_hash['embeddings'] ||= []
      end

      def add_match_and_result(test_step, result)
        @step_or_hook_hash['match'] = create_match_hash(test_step, result)
        @step_or_hook_hash['result'] = create_result_hash(result)
      end

      def add_failed_around_hook(result)
        @step_or_hook_hash = {}
        around_hooks << @step_or_hook_hash
        @step_or_hook_hash['match'] = { 'location' => 'unknown_hook_location:1' }

        @step_or_hook_hash['result'] = create_result_hash(result)
      end

      def encode64(data)
        # strip newlines from the encoded data
        Base64.encode64(data).delete("\n")
      end
    end
  end
end
