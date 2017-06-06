
module Lavigne
  module Cucumber
    class FeatureBuilder
      attr_reader :current_feature, :current_scenario

      def initialize(test_case)
        test_case.describe_source_to(self)
      end

      # Called in initialize via test_case.describe_source_to
      def feature(cuke_feature)
        STDOUT.puts 'FeatureBuilder.feature'
        return if same_feature?(cuke_feature)
        feature_hash = {
            uri: cuke_feature.file,
            feature_id: create_id(cuke_feature),
            keyword: cuke_feature.keyword,
            feature_name: cuke_feature.name,
            description: cuke_feature.description,
            line: cuke_feature.location.line
        }

        @current_feature = ::Lavigne::Models::Cucumber::Feature.new(feature_hash)

        cuke_feature.tags.each do |cuke_tag|
          @current_feature.tags << ::Lavigne::Models::Cucumber::Tag.new( { tag_name: cuke_tag.name, line: cuke_tag.location.line })
        end

        # TODO: Do we need these?
        # cuke_feature.comments.each do |comment|
        #   @current_feature.comments << ::Lavigne::Models::Cucumber::Comment.new({ value: comment.to_s.strip, line: comment.location.line } )
        # end

        @current_feature.elements << current_scenario unless current_scenario.nil?
      end




      def background(background)
        STDOUT.puts 'FeatureBuilder.background'
      end

      def scenario(cuke_scenario)
        STDOUT.puts 'FeatureBuilder.scenario'

        scenario_hash = {
            scenario_id: create_id(cuke_scenario),
            keyword: cuke_scenario.keyword,
            scenario_name: cuke_scenario.name,
            description: cuke_scenario.description,
            line: cuke_scenario.location.line,
            type: 'scenario'
        }
        @current_scenario = ::Lavigne::Models::Cucumber::Scenario.new(scenario_hash)

        cuke_scenario.tags.each do |cuke_tag|
          @current_scenario.tags << ::Lavigne::Models::Cucumber::Tag.new( { tag_name: cuke_tag.name, line: cuke_tag.location.line })
        end

        # TODO: Do we need these?
        # cuke_scenario.comments.each do |comment|
        #   @current_scenario.comments << ::Lavigne::Models::Cucumber::Comment.new({ value: comment.to_s.strip, line: comment.location.line } )
        # end

        current_feature.elements << @current_scenario unless current_feature.nil?
      end

      def scenario_outline(scenario)
        STDOUT.puts 'FeatureBuilder.scenario_outline'
      end

      def examples_table(examples_table)

      end

      def examples_table_row(row)

      end

      def create_id(element)
        element.name.downcase.gsub(/ /, '-')
      end

      def same_feature?(test_case)
        # TODO: use IDs?
        return false if @feature.nil?
        @current_feature.uri == test_case.file && @current_feature.line == test_case.location.line
      end
    end
  end
end
