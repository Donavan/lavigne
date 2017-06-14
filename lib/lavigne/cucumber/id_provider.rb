module Lavigne
  module Cucumber
    class IDProvider
      def feature_id(feature)
        feature.feature_name.downcase.tr(' ', '-')
      end

      def scenario_id(scenario)
        scenario.scenario_name.downcase.tr(' ', '-')
      end

      def scenario_outline_id(scenario, example_id)
        scenario_id(scenario) + ';' + example_id
      end

      def example_id(table, row, _tags)
        table.name.downcase.tr(' ', '-') + ";#{row.number + 1}"
      end
    end
  end
end

