module Lavigne
  module Models
    class LavigneRecord
      include Avromatic::Model.build(schema_name: 'com.lavigne.lavigne_record', mutable: true)
    end
  end
end
