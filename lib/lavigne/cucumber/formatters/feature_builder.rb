
module Lavigne
  module Cucumber
    class FeatureBuilder
      attr_reader :current_feature, :current_scenario

      def initialize(test_case)
        test_case.describe_source_to(self)
      end

      # Called in initialize via test_case.describe_source_to
      def feature(cuke_feature)
        return if same_feature?(cuke_feature)

        feature_hash = _feature_hash(cuke_feature)
        @current_feature = ::Lavigne::Models::Cucumber::Feature.new(feature_hash)

        _extract_and_add_tags(cuke_feature, @current_feature)

        # TODO: Do we need these?
        # cuke_feature.comments.each do |comment|
        #   @current_feature.comments << ::Lavigne::Models::Cucumber::Comment.new({ value: comment.to_s.strip, line: comment.location.line } )
        # end

        @current_feature.elements << current_scenario unless current_scenario.nil?
      end

      def background(_background)
        STDOUT.puts 'FeatureBuilder.background'
      end

      def scenario(cuke_scenario)
        scenario_hash = _scenario_hash(cuke_scenario)
        @current_scenario = ::Lavigne::Models::Cucumber::Scenario.new(scenario_hash)

        _extract_and_add_tags(cuke_scenario, @current_scenario)

        # TODO: Do we need these?
        # cuke_scenario.comments.each do |comment|
        #   @current_scenario.comments << ::Lavigne::Models::Cucumber::Comment.new({ value: comment.to_s.strip, line: comment.location.line } )
        # end

        current_feature.elements << @current_scenario unless current_feature.nil?
      end

      def scenario_outline(_scenario)
        STDOUT.puts 'FeatureBuilder.scenario_outline'
      end

      def examples_table(examples_table)
      end

      def examples_table_row(row)
      end

      def create_id(element)
        element.name.downcase.tr(' ', '-')
      end

      private

      def _feature_hash(cuke_feature)
        {
          uri: cuke_feature.file,
          feature_id: create_id(cuke_feature),
          keyword: cuke_feature.keyword,
          feature_name: cuke_feature.name,
          description: cuke_feature.description,
          line: cuke_feature.location.line
        }
      end

      def _extract_and_add_tags(element, target)
        element.tags.each do |cuke_tag|
          target.tags << ::Lavigne::Models::Cucumber::Tag.new(tag_name: cuke_tag.name, line: cuke_tag.location.line)
        end
      end

      def same_feature?(test_case)
        # TODO: use IDs?
        return false if @current_feature.nil?
        @current_feature.uri == test_case.file && @current_feature.line == test_case.location.line
      end

      def _scenario_hash(cuke_scenario)
        {
          scenario_id: create_id(cuke_scenario),
          keyword: cuke_scenario.keyword,
          scenario_name: cuke_scenario.name,
          description: cuke_scenario.description,
          line: cuke_scenario.location.line,
          type: 'scenario'
        }
      end
    end
  end
end
