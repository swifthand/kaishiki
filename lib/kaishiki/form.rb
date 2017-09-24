##
# Form Object library with the following goals:
# - Use Virtus.model for attribute management and coercion.
# - Use ActiveModel::Validations for validation logic.
# - Use ActiveModel::Naming and ActiveModel::Translation for ease of interoperability
#   with assorted Rails components.
# - Use Normalizr for normalization.

require 'virtus'
require 'active_model'
require 'active_support/json'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'kaishiki/util/class_delegation'
require 'normalizr'

module Kaishiki
  class Form
    extend  ActiveModel::Naming
    extend  ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include Virtus.model
    include Normalizr::Concern

    class << self

      ##
      # So often needed, and annoying to have to do the .map(&:name) yourself
      # in a hundred different places.
      def attribute_names
        attribute_set.map(&:name)
      end

    end

    ##
    # A default status to present when the form is invalid or otherwise cannot
    # be committed. Overriding in subclass encouraged.
    def failure_status
      :unprocessable_entity
    end

    ##
    # The convention for Kaishiki forms is to implement all post-initialization
    # logic (ideally the logic which processes the form) in a single function
    # named commit. There is no requirement that commit be idempotent, or that it
    # only be run once, but in the majority of cases does end up being idempotent
    # and called only once per initialized form.
    def commit
      raise NotImplementedError.new
    end

  end
end
