module Lavigne
  module Models
    class FileHeader
      include Avromatic::Model.build(schema_name: 'com.lavigne.lavigne_file_header')
    end
  end
end
