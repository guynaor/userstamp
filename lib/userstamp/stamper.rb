module Ddb #:nodoc:
  module Userstamp
    module Stamper
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        def model_stamper
          # don't allow multiple calls
          return if self.included_modules.include?(Ddb::Userstamp::Stamper::InstanceMethods)
          send(:extend, Ddb::Userstamp::Stamper::InstanceMethods)
        end
      end

      module InstanceMethods
        # Used to set the stamper for a particular request. See the Userstamp module for more
        # details on how to use this method.
        def stamper=(object)
          object_stamper = if object.is_a?(ActiveRecord::Base)
            object.send("#{object.class.primary_key}".to_sym)
          else
            object
          end

          Thread.current[stamper_unique_key] = object_stamper
        end

        def stamper_unique_key
          "#{self.to_s.downcase}_#{self.object_id}_stamper".freeze
        end

        # Retrieves the existing stamper for the current request.
        def stamper
          Thread.current[stamper_unique_key]
        end

        # Sets the stamper back to +nil+ to prepare for the next request.
        def reset_stamper
          Thread.current[stamper_unique_key] = nil
        end
      end

    end
  end
end

ActiveRecord::Base.send(:include, Ddb::Userstamp::Stamper) if defined?(ActiveRecord)


