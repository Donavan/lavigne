module Lavigne
  module Models
    module Cucumber
      class Scenario
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.scenario', mutable: true)

        def update_step_stats
          self.passing_steps = steps.count { |s| s.status == 'passed' }
          self.failing_steps = steps.count { |s| s.status == 'failed' }
          self.other_steps = steps.count { |s| s.status != 'failed' && s.status != 'passed' }
        end
      end
    end
  end
end
