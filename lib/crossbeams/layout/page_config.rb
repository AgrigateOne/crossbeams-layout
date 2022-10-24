# frozen_string_literal: true

module Crossbeams
  module Layout
    # Configuration for a page and its child elements.
    class PageConfig
      attr_reader :form_object, :name, :options
      attr_accessor :form_values, :form_errors

      CROSSBEAMS = 'crossbeams'
      # Create a new PageConfig.
      # @param [Hash] options the options for applying parameters.
      # @option options [Object] :form_object The object that supplies form data.
      # @option options [String] :name The name of the form. Used as input parameter namespace.
      # @return self.
      def initialize(options = {})
        @form_object = options.delete(:form_object) # || blank_object?
        @form_values = options.delete(:form_values)
        @form_errors = options.delete(:form_errors)
        @name        = options.delete(:name) || CROSSBEAMS
        @options     = options
      end

      # Setter for the form object.
      # If the +name+ has not been set, derive it from the form object's class.
      # @param [Object] obj The object that supplies values to the form.
      # @returns [void]
      def form_object=(obj)
        @form_object = obj
        return unless @name == CROSSBEAMS

        class_name   = obj.class.name || CROSSBEAMS
        @name        = snake_case(name_from_object(class_name))
      end

      private

      # Simplify the class name if the class is a namespaced class.
      # @param class_name [String] The name of a class.
      # @returns [String] The class name - stripped of any preceding namespace text (Module::Class => Class).
      def name_from_object(class_name)
        class_name.split('::').last
      end

      # Helper to snake_case a string.
      def snake_case(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_').downcase
      end
    end
  end
end
