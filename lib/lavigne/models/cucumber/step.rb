module Lavigne
  module Models
    module Cucumber
      class Step
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.step')
      end
    end
  end
end