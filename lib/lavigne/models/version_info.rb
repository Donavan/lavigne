module Lavigne
  module Models
    class VersionInfo
      include Avromatic::Model.build(schema_name: 'com.lavigne.version_info', mutable: true)
    end
  end
end
