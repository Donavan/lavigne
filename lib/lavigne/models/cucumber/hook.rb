module Lavigne
  module Models
    module Cucumber
      class Hook
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.hook', mutable: true)
      end
    end
  end
end