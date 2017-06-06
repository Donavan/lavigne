module Lavigne
  module Models
    class FileHeader
      include Avromatic::Model.build(schema_name: 'com.lavigne.lavigne_file_header', immutable: false)
    end
  end
end
