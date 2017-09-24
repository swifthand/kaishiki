##
# Virtus coercible attribute to attempt to make things JSON-like.
# Very much a work in progress, improvements welcome, just be aware of
# upgrading any existing usage when breaking current functionality.
require 'json'

module Kaishiki
  class JSON < Virtus::Attribute
    def coerce(value)
      if value.kind_of?(Hash)
        value
      elsif value.kind_of?(Array)
        value.map { |elt| coerce(elt) }
      elsif value.kind_of?(String)
        ::JSON.parse(value)
      elsif value.respond_to?(:as_json)
        value.as_json
      elsif value.respond_to?(:to_json)
        ::JSON.parse(value.to_json)
      else
        nil
      end
    end
  end
end
