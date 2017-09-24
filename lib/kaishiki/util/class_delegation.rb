##
# Typing self.class.method_name gets old, and wrapping it in an instance method
# of the same name seems so boiler-plate-y that we might as well make a mixin for it.

require 'active_support/core_ext/module/delegation'

module Kaishiki
  module Util
    module ClassDelegation

      def self.included(base)
        base.extend(ClassMethods)
      end


      module ClassMethods

        def class_delegate(*messages)
          [messages].flatten.each do |msg|
            unless msg.kind_of?(Symbol)
              raise ArgumentError.new("Delegation can only occur for symbols. Received #{msg} which is not a symbol.")
            end
            class_exec do
              define_method(msg, &->(*args) { self.class.send(msg, *args) })
            end
          end
        end

      end

    end
  end
end
