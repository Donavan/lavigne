
module Lavigne
  module Cucumber
    class FeatureBuilder
      attr_reader :current_feature, :current_scenario

      def initialize
      end

      def add_test_case(test_case)
        test_case.describe_source_to(self)
        test_case.feature.background.describe_to(self)
      end

      # Called in add_test_case via test_case.describe_source_to
      def feature(cuke_feature)
        return if same_feature?(cuke_feature)
        STDOUT.puts 'FeatureBuilder.feature'

        @current_feature = ::Lavigne::Models::Cucumber::Feature.new(_feature_hash(cuke_feature))

        _extract_and_add_tags(cuke_feature, @current_feature)

        @current_feature.scenarios << current_scenario unless current_scenario.nil?
        @current_feature.feature_id = Lavigne.id_provider.feature_id(@current_feature)
      end

      def background(background)
        STDOUT.puts "FeatureBuilder.background #{background.name}"
      end

      def scenario(cuke_scenario)
        STDOUT.puts "FeatureBuilder.scenario #{cuke_scenario.name}"
        _new_scenario(cuke_scenario,_scenario_hash(cuke_scenario))
        _extract_and_add_tags(cuke_scenario, current_scenario)
        @current_scenario.test_case_id = Lavigne.id_provider.scenario_id(current_scenario)
      end

      def scenario_outline(cuke_scenario)
        STDOUT.puts 'FeatureBuilder.scenario_outline'
        _new_scenario(cuke_scenario,_scenario_outline_hash(cuke_scenario))
        _extract_and_add_tags(cuke_scenario, current_scenario)
        @current_scenario.tags.concat @examples_table_tags
        @current_scenario.example_row = @row
        @current_scenario.test_case_id = Lavigne.id_provider.scenario_outline_id(current_scenario, @example_id)
      end

      def examples_table(examples_table)
        STDOUT.puts 'FeatureBuilder.examples_table'
        #binding.pry
        # the json file have traditionally used the header row as row 1,
        # wheras cucumber-ruby-core used the first example row as row 1.
        @example_id = create_id(examples_table) + ";#{@row.number + 1}"
        @examples_table_tags = create_tags_array(examples_table.tags)
      end

      def create_tags_array(tags)
        tags_array = []
        tags.each { |cuke_tag| tags_array << ::Lavigne::Models::Tag.new(tag_name: cuke_tag.name, line: cuke_tag.location.line) }
        tags_array
      end

      def examples_table_row(row)
        STDOUT.puts 'FeatureBuilder.examples_table_row'
        #binding.pry;2
        @row = ::Lavigne::Models::Cucumber::Row.new({line: row.line, number: row.number, values: row.values.dup})
        @row.validate!
      end

      def create_id(element)
        element.name.downcase.tr(' ', '-')
      end

      def before_step(test_step)
        return if _internal_hook?(test_step)

        hook_query = ::Cucumber::Formatter::HookQueryVisitor.new(test_step)
        return if hook_query.hook?

        current_scenario.steps << ::Lavigne::Models::Cucumber::Step.new(_create_step_hash(test_step))
      end

      def first_step_after_background?(test_step)
        test_step.source[1].name != @element_hash[:name]
      end

      def after_step(test_step, result)
        return if _internal_hook?(test_step)

        hook_query = ::Cucumber::Formatter::HookQueryVisitor.new(test_step)
        if hook_query.hook?
          _add_hook_result(hook_query, test_step, result)
          return
        end

        current_step = current_scenario.steps.last

        current_step.location = test_step.action_location.to_s
        current_step.status = result.to_sym
        current_step.duration = result.duration.nanoseconds
        current_step.error_message = create_error_message(result) if result.failed? || result.pending?
        @any_step_failed = true if result.failed?
      end

      def create_error_message(result)
        # TODO: Revisit this.  These should be in a new type
        message_element = result.failed? ? result.exception : result
        message = "#{message_element.message} (#{message_element.class})"
        ([message] + message_element.backtrace).join("\n")
      end

      def same_feature?(test_case)
        # TODO: use IDs?
        return false if @current_feature.nil?
        @current_feature.uri == test_case.file && @current_feature.line == test_case.location.line
      end

      private

      def _add_hook_result(hook_query, test_step, result)
        hook = ::Lavigne::Models::Cucumber::Hook.new({ location: test_step.action_location.to_s, duration: result.duration.nanoseconds, status: result.to_sym })
        hook.error_message = create_error_message(result) if result.failed? || result.pending?
        target = current_scenario.steps.last.nil? ? current_scenario : current_scenario.steps.last
        target.send(hook_query.type) << hook
      end

      def _new_scenario(cuke_scenario, scenario_hash)
        @current_scenario = ::Lavigne::Models::Cucumber::Scenario.new(scenario_hash)

        _extract_and_add_tags(cuke_scenario, @current_scenario)

        current_feature.scenarios << @current_scenario unless current_feature.nil?
      end

      def _feature_hash(cuke_feature)
        {
          uri: cuke_feature.file,
          keyword: cuke_feature.keyword,
          feature_name: cuke_feature.name,
          description: cuke_feature.description,
          line: cuke_feature.location.line
        }
      end

      def _extract_and_add_tags(element, target)
        element.tags.each do |cuke_tag|
          target.tags << ::Lavigne::Models::Tag.new(tag_name: cuke_tag.name, line: cuke_tag.location.line)
        end
      end

      def _scenario_hash(cuke_scenario)
        {
          test_case_id: create_id(cuke_scenario),
          line: cuke_scenario.location.line,
          scenario_type: 'scenario'
        }.merge(_scenario_common_hash(cuke_scenario))
      end

      def _scenario_outline_hash(cuke_scenario)
        {
          test_case_id: create_id(cuke_scenario) + ';' + @example_id,
          line: @row.line,
          scenario_type: 'scenario_outline'
        }.merge(_scenario_common_hash(cuke_scenario))
      end

      def _scenario_common_hash(cuke_scenario)
        {
          keyword: cuke_scenario.keyword,
          name: cuke_scenario.name,
          description: cuke_scenario.description,
          test_case_type: 'cucumber'
        }
      end

      def _create_step_hash(test_step)

        step_source = test_step.source.last
        step_hash = {
            keyword: step_source.keyword,
            name: step_source.name,
            line: step_source.location.line,
            background: test_step.source[1].name != current_scenario.name
        }
        step_hash[:rows] = _rows_from_data_table(step_source.multiline_arg) if step_source.multiline_arg.data_table?
        step_hash
      end

      def _rows_from_data_table(data_table)
        data_table.raw.map do |row|
          { values: row }
        end
      end

      def _internal_hook?(test_step)
        test_step.source.last.location.file.include?('lib/cucumber/')
      end
    end
  end
end
