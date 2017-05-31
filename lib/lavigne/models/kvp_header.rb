module Lavigne
  module Models
    class KeyValuePairHeader
      include Avromatic::Model.build(schema_name: 'com.lavigne.kvp_header')
    end
  end
end