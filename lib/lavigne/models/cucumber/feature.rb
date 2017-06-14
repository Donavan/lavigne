module Lavigne
  module Models
    module Cucumber
      class Feature
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.feature', mutable: true)

        def update_scenario_stats
          self.passing_scenarios = scenarios.count { |s| s.status == 'passed' }
          self.failing_scenarios = scenarios.count { |s| s.status == 'failed' }
          self.other_scenarios = scenarios.count { |s| s.status != 'failed' && s.status != 'passed' }
        end
      end
    end
  end
end
