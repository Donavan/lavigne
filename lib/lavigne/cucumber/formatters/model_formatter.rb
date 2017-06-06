# frozen_string_literal: true
require 'base64'
require 'cucumber/formatter/backtrace_filter'
require 'cucumber/formatter/io'
require 'cucumber/formatter/hook_query_visitor'
require 'cucumber/events'
require 'lavigne/models'
require 'lavigne/cucumber/formatters/feature_builder'
require 'pry'

module Lavigne
  module Cucumber
    class ModelFormatter
      attr_reader :writer, :builder

      def initialize(config)
        _init_events(config)
        _init_io(config)
      end

      def on_before_test_case(event)
        test_case = event.test_case

        if builder.nil? || !builder.same_feature?(test_case)
          _write_feature
          @builder = ::Lavigne::Cucumber::FeatureBuilder.new(test_case)
          return
        end
        binding.pry

      end

      private

      def _write_feature
        return if @builder.nil? || @builder.current_feature.nil?
        _write_headers
        record = { 'rec_type' =>  :feature.to_s, 'data' => builder.current_feature.avro_raw_value }

        begin
          @writer << record
        rescue
          # TODO: Scope this
          # This will raise an exception with meaningful output.
          Avro::SchemaValidator.validate!( Lavigne.schema, hdr )
        end
      end

      def _write_headers
        return unless @headers_needed
        Lavigne.write_headers(@writer)
        @headers_needed = false
      end

      def _init_events(config)
        config.on_event :before_test_case, &method(:on_before_test_case)
        #config.on_event :after_test_case, &method(:on_after_test_case)
        #config.on_event :before_test_step, &method(:on_before_test_step)
        #config.on_event :after_test_step, &method(:on_after_test_step)
        #config.on_event :finished_testing, &method(:on_finished_testing)
      end

      def _init_io(config)
        io = File.open(config.out_stream, 'wb')
        @headers_needed = true
        @writer = ::Lavigne.datafile_writer(io)
        at_exit do
          @writer.close unless @writer.writer.closed?
        end
      end
    end
  end
end
