module Lavigne
  module Models
    class LavigneHeader
      include Avromatic::Model.build(schema_name: 'com.lavigne.lavigne_header', immutable: false)
    end
  end
end
