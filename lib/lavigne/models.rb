require 'avromatic'

# TODO: fix registry URL
Avromatic.configure do |config|
  config.schema_store = Lavigne.schema_store
  config.registry_url = 'https://builder:avro@avro-schema-registry.salsify.com'
  config.build_messaging!
end
require 'lavigne/models/kv_pair'
require 'lavigne/models/kvp_header'
require 'lavigne/models/run_info'
require 'lavigne/models/lavigne_file_header'
require 'lavigne/models/lavigne_header'

# Cucumber must be included before the record
require 'lavigne/models/cucumber'
require 'lavigne/models/lavigne_record'