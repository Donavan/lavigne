require 'avromatic'

# TODO: fix registry URL
Avromatic.configure do |config|
  config.schema_store = Lavigne.schema_store
  config.registry_url = 'https://builder:avro@avro-schema-registry.salsify.com'
  config.build_messaging!
end

module Lavigne
  class ModelWriter
    attr_accessor :writers_schema
    def initialize(writers_schema = Lavigne.schema)
      @writers_schema = writers_schema
    end

    def write(datum, encoder)
      encoder.writer.write datum.avro_raw_value
    end
  end

  def self.model_datafile_writer(file)
    Avro::DataFile::Writer.new(file, ModelWriter.new, Lavigne.schema)
  end
end

require 'lavigne/models/kv_pair'
require 'lavigne/models/kvp_header'
require 'lavigne/models/run_info'
require 'lavigne/models/lavigne_file_header'
require 'lavigne/models/lavigne_header'
require 'lavigne/models/tag'
require 'lavigne/models/test_case'

# Cucumber must be included before the record
require 'lavigne/models/cucumber'
require 'lavigne/models/lavigne_record'
