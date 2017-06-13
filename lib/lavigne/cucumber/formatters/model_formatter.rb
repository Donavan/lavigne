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
        STDOUT.puts 'on_before_test_case'
        test_case = event.test_case

        _write_feature unless builder.nil? || builder.same_feature?(test_case.feature)

        @builder = ::Lavigne::Cucumber::FeatureBuilder.new if builder.nil? || !builder.same_feature?(test_case.feature)
        @builder.add_test_case(test_case)
      end

      def on_before_test_step(event)
        builder.before_step(event.test_step)
      end

      def on_after_test_step(event)
        builder.after_step(event.test_step, event.result.with_filtered_backtrace(::Cucumber::Formatter::BacktraceFilter))
      end

      def on_after_test_case(event)
        result = event.result.with_filtered_backtrace(::Cucumber::Formatter::BacktraceFilter)
        #add_failed_around_hook(result) if result.failed? && !@any_step_failed

        STDOUT.puts 'on_after_test_case'
        _update_scenario_status(result)
      end

      def on_finished_testing(_event)
        _write_feature
      end

      private

      def _update_scenario_status(result)
        if (failing_step = builder.current_scenario.steps.find { |step| step.status == 'failed' })
          builder.current_scenario.status = failing_step.status
          builder.current_scenario.error_message = failing_step.error_message
          return
        end

        if result.failed?
          builder.current_scenario.status = result.to_sym
          builder.current_scenario.error_message = builder.create_error_message(result)
          return
        end

        if (failing_step = builder.current_scenario.steps.find { |step| step.status == 'skipped' })
          builder.current_scenario.status = failing_step.status
          builder.current_scenario.error_message = failing_step.error_message
          return
        end

        builder.current_scenario.status = 'passed'
      end

      def _write_feature
        return if @builder.nil? || @builder.current_feature.nil?
        _write_headers
        begin
          record = { 'rec_type' => :feature.to_s, 'data' => builder.current_feature.avro_raw_value }
        rescue ::Avro::IO::AvroTypeError => ex
          binding.pry;2

          # This will raise an exception with meaningful output.
          builder.current_feature.validate!
        end

        begin
          @writer << record
        rescue ::Avro::SchemaValidator::ValidationError
          # This will raise an exception with meaningful output.
          Avro::SchemaValidator.validate!(Lavigne.schema, record)
        end
      end

      def _write_headers
        return unless @headers_needed
        Lavigne.write_headers(@writer)
        @headers_needed = false
      end

      def _init_events(config)
        config.on_event :before_test_case, &method(:on_before_test_case)
        config.on_event :after_test_case, &method(:on_after_test_case)
        config.on_event :before_test_step, &method(:on_before_test_step)
        config.on_event :after_test_step, &method(:on_after_test_step)
        config.on_event :finished_testing, &method(:on_finished_testing)
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
