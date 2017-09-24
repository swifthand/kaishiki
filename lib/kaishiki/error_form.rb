##
# An implementation of Kaishiki::Form for the incredibly common case of a form
# which is in a state of error, not because the attributes are incorrectly set, but
# because the form itself cannot even be built by the system which requires it.
#
# The simplest example is a request to update a form for a record which has been removed.
# It would be ideal to present an object polymorphic with the interface of the
# Kaishiki::Form interface, for a more "tell, don't ask" style, rather than having the
# consuming code have to ask "Are you a form? Or are you some other error object?"
#
# Convenience class methods are provided for common error cases, rather than having to
# repeat the same message formatting logic in a hundred different places that construct
# an ErrorForm for a similar reason.

require 'kaishiki/form'

module Kaishiki
  class ErrorForm < Kaishiki::Form

    ##
    # Convenience class methods for common error cases.
    class << self

      def record_not_found(record_type_name, **search_criteria)
        message =
          if search_criteria.any?
            criteria_description = search_criteria.map do |key, val|
              "#{key.to_s.gsub('_', ' ')} of \"#{val}\""
            end.join(', ')
            "Could not find #{record_type_name} with #{criteria_description}"
          else
            "Could not find #{record_type_name}"
          end
        new(status: :not_found, message: message)
      end


      def unauthorized(action, record_type_name)
        message = "You do not have permission to #{action} that #{record_type_name}"
        new(status: :unauthorized, message: message)
      end

    end


    attr_reader :failure_status, :message

    ##
    # Straightforward initialization. Status could be anything but is likely to be
    # one of the HTTP status codes, e.g. :not_found or :unprocessable_entity.
    def initialize(status: , message: )
      @failure_status = status
      @message        = message
      self.errors.add(:base, message)
    end

    ##
    # `context = nil` matches signature from ActiveModel::Validations
    def valid?(context = nil)
      false
    end

    ##
    # `context = nil` matches signature from ActiveModel::Validations
    def invalid?(context = nil)
      true
    end

    ##
    # Will likely rarely be used, but is definitely false.
    def commit
      false
    end

  end
end
