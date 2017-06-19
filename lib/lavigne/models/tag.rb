module Lavigne
  module Models
    class Tag
      include Avromatic::Model.build(schema_name: 'com.lavigne.tag', mutable: true)
    end
  end
end
