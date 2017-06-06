module Lavigne
  module Models
    module Cucumber
      class Row
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.row', mutable: true)
      end
    end
  end
end
