module Lavigne
  module Models
    class KeyValuePair
      include Avromatic::Model.build(schema_name: 'com.lavigne.kv_pair', immutable: false)
    end
  end
end
