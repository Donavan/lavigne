module Lavigne
  module Models
    module Cucumber
      class Row
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.row')
      end
    end
  end
end