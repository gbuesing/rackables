# This file not required by default -- to add this feature, you need to explicitly require, ex:
#
#   require 'rackables/more/env_inquirer'
module Rack
  # Adds pretty reader and query methods for ENV['RACK_ENV'] value.
  # A copy of Rails' Rails.env for Rack apps.
  #
  # Examples:
  #
  #   Rack.env                # => "development"
  #   Rack.env.development?   # => true
  def self.env
    @env ||= Utils::StringInquirer.new(ENV["RACK_ENV"] || "development")
  end

  module Utils
    # TAKEN FROM ACTIVE SUPPORT
    class StringInquirer < String
      def method_missing(method_name, *arguments)
        if method_name.to_s[-1,1] == "?"
          self == method_name.to_s[0..-2]
        else
          super
        end
      end
    end
  end
end
