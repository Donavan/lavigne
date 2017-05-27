module Lavigne
  module CucumberTwoFour
    # This class is responsible for providing the bits that tend to change
    # from one Cucumber version to another
    class Shim

      # returns a JSON schema for this version of Cucumber
      def json_schema
        @schema_json ||= Avro::Builder.build do
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
            optional :before, :array, items: :hook
            optional :after, :array, items: :hook
            optional :around, :array, items: :hook
          end

          record :scenario do
            optional :id, :string
            required :keyword, :string
            required :name, :string
            required :description, :string
            required :line, :long
            required :type, :string
            optional :tags, :array, items: :tag
            optional :output, :array, items: :string
            optional :before, :array, items: :hook
            optional :after, :array, items: :hook
            optional :around, :array, items: :hook
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
            optional :output, :array, items: :string
            optional :before, :array, items: :hook
            optional :after, :array, items: :hook
            optional :around, :array, items: :hook
          end
        end
      end

      def formatter
        require 'lavigne/cucumber/formatters/cucumber_two_four_formatter'
        Lavigne::CucumberTwoFour::Formatter
      end
    end
  end
end
