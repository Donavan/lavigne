module Lavigne
  module Models
    module Cucumber
      class Tag
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.tag')
      end
    end
  end
end