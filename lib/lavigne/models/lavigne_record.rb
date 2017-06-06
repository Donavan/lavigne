module Lavigne
  module Models
    class LavigneRecord
      include Avromatic::Model.build(schema_name: 'com.lavigne.lavigne_record', immutable: false)
    end
  end
end