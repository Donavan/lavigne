module Lavigne
  module Models
    module Cucumber
      class Step
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.step', mutable: true)
      end
    end
  end
end
