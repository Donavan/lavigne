module Lavigne
  module Models
    class TestCase
      include Avromatic::Model.build(schema_name: 'com.lavigne.test_case', mutable: true)
    end
  end
end
