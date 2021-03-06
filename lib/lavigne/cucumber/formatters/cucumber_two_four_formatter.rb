# frozen_string_literal: true

require 'base64'
require 'cucumber/formatter/backtrace_filter'
require 'cucumber/formatter/io'
require 'cucumber/formatter/hook_query_visitor'
require 'cucumber/events'
require 'lavigne/cucumber/formatters/base_formatter'
require 'lavigne/cucumber/formatters/feature_builder'
require 'pry'

module Lavigne
  module CucumberTwoFour
    class Formatter < ::Lavigne::Cucumber::BaseFormatter
      attr_reader :builder
      def initialize(config)
        super(config)
        config.on_event :before_test_case, &method(:on_before_test_case)
        config.on_event :after_test_case, &method(:on_after_test_case)
        config.on_event :before_test_step, &method(:on_before_test_step)
        config.on_event :after_test_step, &method(:on_after_test_step)
        config.on_event :finished_testing, &method(:on_finished_testing)
        @builder = ::Lavigne::Cucumber::FeatureBuilder
      end

      def write_headers
        return unless @headers_needed
        Lavigne.write_headers(@writer)
        @headers_needed = false
      end

      def on_before_test_case(event)
        write_headers
        test_case = event.test_case

        @writer << { 'feature' => builder.feature } unless builder.feature.nil?
        builder.new_feature
        # builder = Builder.new(test_case)

        _new_feature_hash_if_needed(event, builder)
        @test_case_hash = builder.test_case_hash
        if builder.background?
          feature_elements << builder.background_hash
          @element_hash = builder.background_hash
        else
          feature_elements << @test_case_hash
          @element_hash = @test_case_hash
        end
        @any_step_failed = false
      end

      def on_before_test_step(event)
        test_step = event.test_step

        return if internal_hook?(test_step)
        hook_query = ::Cucumber::Formatter::HookQueryVisitor.new(test_step)
        if hook_query.hook?
          @step_or_hook_hash = {}
          hooks_of_type(hook_query) << @step_or_hook_hash
          return
        end
        if first_step_after_background?(test_step)
          feature_elements << @test_case_hash
          @element_hash = @test_case_hash
        end

        @step_or_hook_hash = create_step_hash(test_step.source.last)
        steps << @step_or_hook_hash
        @step_hash = @step_or_hook_hash
      end

      def on_after_test_step(event)
        test_step = event.test_step

        result = event.result.with_filtered_backtrace(::Cucumber::Formatter::BacktraceFilter)

        return if internal_hook?(test_step)

        add_match_and_result(test_step, result)
        @any_step_failed = true if result.failed?
      end

      def on_after_test_case(event)
        result = event.result.with_filtered_backtrace(::Cucumber::Formatter::BacktraceFilter)
        add_failed_around_hook(result) if result.failed? && !@any_step_failed
      end

      def on_finished_testing(_event)
        @writer.close
      end

      private

      def same_feature_as_previous_test_case?(feature)
        current_feature['uri'] == feature.file && current_feature['line'] == feature.location.line
      end

      def first_step_after_background?(test_step)
        test_step.source[1].name != @element_hash['name']
      end

      def internal_hook?(test_step)
        test_step.source.last.location.file.include?('lib/cucumber/')
      end

      def hooks_of_type(hook_query)
        case hook_query.type
        when :before
            before_hooks
        when :after
            after_hooks
        when :after_step
            after_step_hooks
          else
            raise 'Unkown hook type ' + hook_query.type.to_s
        end
      end

      def create_step_hash(step_source)
        step_hash = {
          'keyword' => step_source.keyword,
            'name' => step_source.name,
            'line' => step_source.location.line
        }
        step_hash['comments'] = Formatter.create_comments_array(step_source.comments) unless step_source.comments.empty?
        step_hash['doc_string'] = create_doc_string_hash(step_source.multiline_arg) if step_source.multiline_arg.doc_string?
        step_hash['rows'] = create_data_table_value(step_source.multiline_arg) if step_source.multiline_arg.data_table?
        step_hash
      end

      def create_doc_string_hash(doc_string)
        content_type = doc_string.content_type ? doc_string.content_type : ''
        {
          'value' => doc_string.content,
            'content_type' => content_type,
            'line' => doc_string.location.line
        }
      end

      def create_data_table_value(data_table)
        data_table.raw.map do |row|
          { 'cells' => row }
        end
      end

      def create_match_hash(test_step, _result)
        { 'location' => test_step.action_location.to_s }
      end

      def create_result_hash(result)
        result_hash = {
          'status' => result.to_sym.to_s
        }
        result_hash['error_message'] = create_error_message(result) if result.failed? || result.pending?
        result.duration.tap { |duration| result_hash['duration'] = duration.nanoseconds }
        result_hash
      end

      def create_error_message(result)
        message_element = result.failed? ? result.exception : result
        message = "#{message_element.message} (#{message_element.class})"
        ([message] + message_element.backtrace).join("\n")
      end

      class Builder
        attr_reader :feature_hash, :background_hash, :test_case_hash

        def initialize(test_case)
          @background_hash = nil
          test_case.describe_source_to(self)
          test_case.feature.background.describe_to(self)
        end

        def background?
          @background_hash != nil
        end

        def feature(feature)
          @feature_hash = {
            'uri' => feature.file,
              'id' => create_id(feature),
              'keyword' => feature.keyword,
              'name' => feature.name,
              'description' => feature.description,
              'line' => feature.location.line
          }
          unless feature.tags.empty?
            @feature_hash['tags'] = create_tags_array(feature.tags)
            if @test_case_hash['tags']
              @test_case_hash['tags'] = @feature_hash['tags'] + @test_case_hash['tags']
            else
              @test_case_hash['tags'] = @feature_hash['tags']
            end
          end
          @feature_hash['comments'] = Formatter.create_comments_array(feature.comments) unless feature.comments.empty?
          @test_case_hash['id'].insert(0, @feature_hash['id'] + ';')
        end

        def background(background)
          @background_hash = {
            'keyword' => background.keyword,
              'name' => background.name,
              'description' => background.description,
              'line' => background.location.line,
              'type' => 'background'
          }
          @background_hash['comments'] = Formatter.create_comments_array(background.comments) unless background.comments.empty?
        end

        def scenario(scenario)
          @test_case_hash = {
            'id' => create_id(scenario),
              'keyword' => scenario.keyword,
              'name' => scenario.name,
              'description' => scenario.description,
              'line' => scenario.location.line,
              'type' => 'scenario'
          }
          @test_case_hash['tags'] = create_tags_array(scenario.tags) unless scenario.tags.empty?
          @test_case_hash['comments'] = Formatter.create_comments_array(scenario.comments) unless scenario.comments.empty?
        end

        def scenario_outline(scenario)
          @test_case_hash = {
            'id' => create_id(scenario) + ';' + @example_id,
              'keyword' => scenario.keyword,
              'name' => scenario.name,
              'description' => scenario.description,
              'line' => @row.location.line,
              'type' => 'scenario'
          }
          tags = []
          tags += create_tags_array(scenario.tags) unless scenario.tags.empty?
          tags += @examples_table_tags if @examples_table_tags
          @test_case_hash['tags'] = tags unless tags.empty?
          comments = []
          comments += Formatter.create_comments_array(scenario.comments) unless scenario.comments.empty?
          comments += @examples_table_comments if @examples_table_comments
          comments += @row_comments if @row_comments
          @test_case_hash['comments'] = comments unless comments.empty?
        end

        def examples_table(examples_table)
          # the json file have traditionally used the header row as row 1,
          # wheras cucumber-ruby-core used the first example row as row 1.
          @example_id = create_id(examples_table) + ";#{@row.number + 1}"

          @examples_table_tags = create_tags_array(examples_table.tags) unless examples_table.tags.empty?
          @examples_table_comments = Formatter.create_comments_array(examples_table.comments) unless examples_table.comments.empty?
        end

        def examples_table_row(row)
          @row = row
          @row_comments = Formatter.create_comments_array(row.comments) unless row.comments.empty?
        end

        private

        def create_id(element)
          element.name.downcase.tr(' ', '-')
        end

        def create_tags_array(tags)
          tags_array = []
          tags.each { |tag| tags_array << { 'name' => tag.name, 'line' => tag.location.line } }
          tags_array
        end
      end
    end

    def self.create_comments_array(comments)
      comments_array = []
      comments.each { |comment| comments_array << { 'value' => comment.to_s.strip, 'line' => comment.location.line } }
      comments_array
    end
  end
end
