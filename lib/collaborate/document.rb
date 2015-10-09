module Collaborate
  # Defines a text-based document that can be collaboratively edited.
  module Document
    extend ActiveSupport::Concern

    included do
      after_initialize :setup_collaborative_attributes
    end

    class_methods do
      def collaborative_attributes(*attributes)
        return @collaborative_attributes if attributes.size == 0

        @collaborative_attributes = attributes.map(&:to_s)

        bind_collaborative_document_attributes
      end

      private

      def bind_collaborative_document_attributes
        collaborative_attributes.each do |attribute|
          bind_collaborative_document_attribute(attribute)
        end
      end

      def bind_collaborative_document_attribute(attribute)
        define_method("collaborative_#{attribute}") do
          collaborative_attribute(attribute).value
        end

        define_method("collaborative_#{attribute}=") do |value|
          collaborative_attribute(attribute).value = value
        end
      end
    end

    def collaborative_attribute(attribute_name)
      @collaborative_attributes[attribute_name.to_s]
    end

    def apply_operation(data)
      operation = OT::TextOperation.from_a data['operation']
      attribute = data['attribute']
      version   = data['version']

      collaborative_attribute(attribute).apply_operation(operation, version)
    end

    def clear_collaborative_cache(attribute)
      collaborative_attribute(attribute).clear_cache
    end

    private

    def setup_collaborative_attributes
      @collaborative_attributes = {}

      self.class.collaborative_attributes.each do |attribute|
        @collaborative_attributes[attribute] = DocumentAttribute.new(self, attribute)
      end
    end
  end
end
