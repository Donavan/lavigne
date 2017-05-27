require 'lavigne/version'
require 'avro/builder'
module Lavigne

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
    features.each { |feature| writer << feature }
  end

  def self.save_features(features, filename)
    file = File.open(filename, 'wb')
    writer = Lavigne.datafile_writer(file)
    self.write_features(features, writer)
  ensure
    writer.close
  end
end
