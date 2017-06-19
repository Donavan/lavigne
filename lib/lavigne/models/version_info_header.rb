module Lavigne
  module Models
    class VersionInfoHeader
      include Avromatic::Model.build(schema_name: 'com.lavigne.version_info_header', mutable: true)
    end
  end
end
