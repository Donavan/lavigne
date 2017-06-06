module Lavigne
  module Models
    module Cucumber
      class Match
        include Avromatic::Model.build(schema_name: 'com.lavigne.cucumber.match_rec', mutable: true)
      end
    end
  end
end