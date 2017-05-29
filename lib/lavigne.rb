require 'lavigne/version'
require 'avro/builder'

module Lavigne

  ROOT = File.expand_path(File.dirname(__FILE__))
  DSL_ROOT = File.realpath(File.join(ROOT, '..', 'avro', 'dsl'))
  Avro::Builder.add_load_path(DSL_ROOT)

  CURRENT_RUN_INFO_VERSION = 1

  class << self
    def respond_to?(meth)
      instance.respond_to?(meth)
    end

    def method_missing(meth, *args)
      instance.send(meth, *args)
    end

    def instance
      @instance ||= _instance_for(::Cucumber::VERSION)
    end

    def _instance_for(version)
      case version
        when /^2\.4/
          require 'lavigne/cucumber/shims/cucumber_two_four_shim'
          CucumberTwoFour::Shim.new
        else
          raise 'Unsupported Cucumber version'
      end
    end
  end

  def self.schema
    @@schema ||= Avro::Schema.parse(Lavigne.json_schema)
  end

  def self.json_schema
    Avro::Builder::build_dsl do
      namespace 'com.lavigne'
      import 'lavigne_record'
    end.to_json
  end


  def self.header_datum_writer
    Avro::IO::DatumWriter.new(Lavigne.header_schema)
  end

  def self.header_datafile_writer(file)
    Avro::DataFile::Writer.new(file, Lavigne.header_datum_writer, Lavigne.header_schema)
  end

  def self.datum_writer
    Avro::IO::DatumWriter.new(Lavigne.schema)
  end

  def self.datafile_writer(file)
    Avro::DataFile::Writer.new(file, Lavigne.datum_writer, Lavigne.schema)
  end

  def self.datafile_reader(file)
    Avro::DataFile::Reader.new(file, Avro::IO::DatumReader.new)
  end

  def self.write_features(features, writer)
    features.each { |feature| writer << { 'feature' => feature } }
  end

  CURRENT_HEADER_INFO = {
                          'lavigne_version' => ::Lavigne::VERSION,
                          'ruby_version' => "#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}".freeze,
                          'cucumber_version' => ::Cucumber::VERSION.chomp,
  }

  def self.write_headers(writer, other_headers = [])
    writer << { 'header' => { 'type' => 'file_header', 'header' => CURRENT_HEADER_INFO } }
    writer << { 'header' => { 'type' => 'run_info', 'header' => Lavigne.run_info } } unless Lavigne.run_info.nil?
    other_headers.each {|header| writer << { 'header' => { 'type' => 'kvp', 'header' => header } } }
    writer << { 'header' => { 'type' => 'headers_end' } }
  end



  def self.save_features(features, filename, other_headers = [])
    file = File.open(filename, 'wb')
    writer = Lavigne.datafile_writer(file)
    self.write_headers(writer, other_headers)
    self.write_features(features, writer)
  ensure
    writer.close
  end
end
