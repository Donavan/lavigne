module Lavigne
  module Models
    module Cucumber
      class Result
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.result_rec')
      end
    end
  end
end