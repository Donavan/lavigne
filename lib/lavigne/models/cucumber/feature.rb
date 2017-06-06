module Lavigne
  module Models
    module Cucumber
      class Feature
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.feature', mutable: true)
      end
    end
  end
end

