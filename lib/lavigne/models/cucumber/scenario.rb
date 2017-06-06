module Lavigne
  module Models
    module Cucumber
      class Scenario
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.scenario', mutable: true)
      end
    end
  end
end