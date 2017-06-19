module Lavigne
  module Models
    module Cucumber
      class Feature
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.feature', mutable: true)

        def update_scenario_stats
          self.passing_test_cases = scenarios.count { |s| s.status == 'passed' }
          self.failing_test_cases = scenarios.count { |s| s.status == 'failed' }
          self.other_test_cases = scenarios.count { |s| s.status != 'failed' && s.status != 'passed' }
        end
      end
    end
  end
end
