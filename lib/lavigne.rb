require 'lavigne/version'
require 'avro/builder'
module Lavigne
  def self.json_schema
    @@schema_json ||= Avro::Builder.build do
      namespace 'com.lavigne.cucumber'

      record :tag do
        required :name, :string
        required :line, :long
      end

      record :row do
        required :cells, :array, items: :string
      end

      record :embedding do
        required :mime_type, :string
        required :data, :string
      end

      record :match_rec do
        required :location, :string
      end

      record :result_rec do
        required :status, :string
        optional :duration, :long
      end

      record :hook do
        required :match, :match_rec
        required :result, :result_rec
        optional :output, :array, items: :string
      end

      record :step do
        required :keyword, :string
        required :name, :string
        required :line, :long
        required :match, :match_rec
        required :result, :result_rec
        optional :embeddings, :array, items: :embedding
        optional :output, :array, items: :string
        optional :rows, :array, items: :row
      end

      record :scenario do
        optional :id, :string
        required :keyword, :string
        required :name, :string
        required :description, :string
        required :line, :long
        required :type, :string
        optional :tags, :array, items: :tag
        optional :before, :array, items: :hook
        optional :after, :array, items: :hook
        required :steps, :array, items: :step
      end

      record :feature do
        required :uri, :string
        required :id, :string
        required :keyword, :string
        required :name, :string
        required :description, :string
        required :line, :long
        optional :tags, :array, items: :tag
        required :elements, :array, items: :scenario
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
