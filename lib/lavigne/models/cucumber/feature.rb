module Lavigne
  module Models
    module Cucumber
      class Feature
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.feature')
      end
    end
  end
end

