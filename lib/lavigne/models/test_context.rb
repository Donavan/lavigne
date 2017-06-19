module Lavigne
  module Models
    class TestContext
      include Avromatic::Model.build(schema_name: 'com.lavigne.test_context', mutable: true)
    end
  end
end
