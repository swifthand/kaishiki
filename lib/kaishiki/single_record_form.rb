##
# Among Form Objects, the most common case is to provide an interface to modify
# a model class which inherits from ActiveRecord::Base. SingleRecordForm is a collection
# of useful default behaviors for this case.
#
# Note that since we are unconcerned with the model as an abstraction for "modeling"
# business logic, it is internally referred to as "record", because here it is being
# treated mostly as a dumb adapter for a database record.

require 'kaishiki/form'

module Kaishiki
  class SingleRecordForm < Kaishiki::Form
    include Util::ClassDelegation

    class << self

      ##
      # It is often convenient to know the ActiveRecord::Base class for which
      # an subclassing form is meant to wrap. Almost all subclasses of SingleRecordForm
      # will want to declare this.
      def for_record(record_class)
        @record_class = record_class
      end
      alias_method :record_class=,  :for_record

      ##
      # The ActiveRecord::Base class whose instances a subclass intends to operate on.
      def record_class
        @record_class || (raise NotImplementedError.new(
          "Please declare ::record_class when using logic which depends on it.\n"\
          "This includes the default initialize method for Kaishiki::SingleRecordForm.\n"\
          "If you do not intend to use the default @record instance variable, please\n"\
          "implement your own initialize method."
        ))
      end

      ##
      # A class macro for declaring that one or more attributes can be directly
      # assigned from the form value (if valid) to the record.
      def directly_assign(*attr_names, **direct_mapping)
        directly_assignable_attributes.merge(attr_names)
        directly_mappable_attributes.merge!(direct_mapping)
      end

      ##
      # Attributes which can be directly assigned from the form's value to the record.
      def directly_assignable_attributes
        @directly_assignable_attributes ||= Set.new
      end

      ##
      # Attributes which can be directly assigned if mapped to another name.
      def directly_mappable_attributes
        @directly_mappable_attributes ||= {}
      end

    end

    class_delegate  :record_class,
                    :attribute_names,
                    :directly_assignable_attributes,
                    :directly_mappable_attributes

    delegate :transaction, to: :record

    attr_reader :record

    ##
    # Given a `record` (or a having built a default one), any attributes that are
    # specified as shared in a ::directly_assign call will be summoned as the initial
    # values for the form object.
    def initialize(record = default_new_record, **attrs)
      @record = record

      assignable_attrs = directly_assignable_attributes.map do |attr_name|
        [attr_name, record.public_send(attr_name)]
      end.to_h

      mappable_attrs = directly_mappable_attributes.map do |form_attr_name, record_attr_name|
        [form_attr_name, record.send(record_attr_name)]
      end.to_h

      super(**assignable_attrs.merge(mappable_attrs).merge(attrs))
    end

  private ######################################################################

    ##
    # Override this for more specific initialization behavior of new record objects,
    # for the case where an initial record is not provided.
    def default_new_record
      record_class.new
    end

    ##
    # Acts on the assginment of directly-assignable attributes as declared via the
    # `directly_assign` class macro.
    def apply_direct_assignments
      directly_assignable_attributes.each do |attr_name|
        record.send("#{attr_name}=", self.send(attr_name))
      end
      directly_mappable_attributes.each do |form_attr, record_attr|
        record.send("#{record_attr}=", self.send(form_attr))
      end
    end

    ##
    # A convenience method for propagating errors of an underlying record back on to
    # a form's errors list (accessible via `#errors`).
    #
    # Generally speaking, the validations for a form object should be a superset
    # of the validations and invariants enforced by any underlying ActiveModel or
    # ActiveRecord instance. In the event that this is not the case, or in the event
    # of transient errors (e.g. LAN cable on fire) result in the record (or whatever
    # is provided as the :from argument) having separate errors from the form, the
    # result would be a form that failed to persist a record, but reports no errors.
    #
    # That's no good. This might assist in avoiding the situation.
    #
    # The #propagate_errors method additionally attempts to avoid duplicates of the
    # same error for the same attribute, and will
    def propagate_errors(from: record)
      from.errors.each do |attr_name, error_message|
        next if errors.keys.include?(attr_name) && errors[attr_name].include?(error_message)
        errors.add(attr_name, error_message)
      end
    end

  end
end
