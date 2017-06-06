module Lavigne
  module Models
    class RunInfo
      include Avromatic::Model.build(schema_name: 'com.lavigne.run_info', immutable: false)
    end
  end
end
