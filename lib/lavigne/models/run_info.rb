module Lavigne
  module Models
    class RunInfo
      include Avromatic::Model.build(schema_name: 'com.lavigne.run_info', mutable: true)
    end
  end
end
