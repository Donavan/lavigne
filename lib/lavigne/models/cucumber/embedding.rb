module Lavigne
  module Models
    module Cucumber
      class Embedding
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.embedding')
      end
    end
  end
end
