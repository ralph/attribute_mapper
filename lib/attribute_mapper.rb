module AttributeMapper
  
  def self.included(model)
    model.extend ClassMethods
    model.send(:include, InstanceMethods)
  end
  
  module ClassMethods # @private
    
    # Map a column in your table to a human-friendly attribute on your model. When
    # ++attribute is accessed, it will return the key from the mapping hash. When
    # the attribute is updated, the value from the mapping hash is written to the
    # database.
    #
    # A class method is also added providing access to the mapping
    # hash, i.e. defining an attribute ++status++ will add a
    # ++statuses++ class method that returns the hash passed to the
    # ++:to++ option.
    #
    # Predicates are also added to each object for each attribute. If you have a key
    # ++open++ in your mapping, your objects will have an ++open?++ method that
    # returns true if the attribute value is ++:open++
    #
    # @example Define a Ticket model with a status column that maps to open or closed
    #   map_attribute :status, :to => {:open => 1, :closed => 2}
    #
    # @param [String] attribute the column to map on
    # @param [Hash] options the options for this attribute
    # @option options [Hash] :to The enumeration to use for this attribute. See example above.
    def map_attribute(attribute, options)
      mapping = options[:to]
      verify_existence_of attribute
      add_accessor_for    attribute, mapping
      add_predicates_for  attribute, mapping.keys
      override            attribute
    end

    private
      def add_accessor_for(attribute, mapping)
        class_eval(<<-EVAL)
          class << self
            def #{attribute.to_s.pluralize}
              #{mapping.inspect}
            end
          end
        EVAL
        end

        def add_predicates_for(attribute, names)
          names.each do |name|
            class_eval(<<-RUBY)
              def #{name}?
                self.#{attribute} == :#{name}
              end
            RUBY
          end
        end
    
      def override(*args)
        override_getters *args
        override_setters *args
      end
      
      def override_getters(attribute)
        class_eval(<<-EVAL)
          def #{attribute}
            self.class.#{attribute.to_s.pluralize}.invert[read_attribute(:#{attribute})]
          end
        EVAL
      end
      
      def override_setters(attribute)
        class_eval(<<-EVAL)
          def #{attribute}=(raw_value)
            value = resolve_value_of :#{attribute}, raw_value
            write_attribute(:#{attribute}, value)
          end
        EVAL
      end
      
      def verify_existence_of(attribute)
        raise ArgumentError, "`#{attribute}' is not an attribute of `#{self}'" unless column_names.include?(attribute.to_s)
      end
  end
  
  module InstanceMethods
    private
      def resolve_value_of(attribute, raw_value)
        check_value = raw_value.is_a?(String) ? raw_value.to_sym : raw_value
        mapping = self.class.send(attribute.to_s.pluralize)
        raise ArgumentError, "`#{check_value}' not present in attribute mapping `#{mapping.inspect}'" unless mapping.to_a.flatten.include? check_value
        mapping.include?(check_value) ? mapping[check_value] : check_value
      end
  end
end
