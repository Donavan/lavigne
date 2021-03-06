require 'lavigne/cucumber/shims/base_shim'
module Lavigne
  module CucumberTwoFour
    # This class is responsible for providing the bits that tend to change
    # from one Cucumber version to another
    class Shim < ::Lavigne::Cucumber::BaseShim
      def formatter
        require 'lavigne/cucumber/formatters/model_formatter'
        ::Lavigne::Cucumber::ModelFormatter
      end
    end
  end
end
