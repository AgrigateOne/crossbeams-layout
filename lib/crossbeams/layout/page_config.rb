module Crossbeams
  module Layout
    # Configuration for a page and its child elements.
    class PageConfig
      attr_reader :form_object, :name, :options
      def initialize(options = {})
        @form_object = options.delete(:form_object) # || blank_object?
        @name        = options.delete(:name) || 'crossbeams'
        @options     = options
      end

      def form_object=(obj)
        @form_object = obj
        class_name   = obj.class.name || 'crossbeams'
        @name        = name_from_object(class_name).downcase
      end

      private

      # Simplify the class name if the class is a ROM::Struct class.
      # @param class_name [String] The name of a class.
      # @returns [String] The class name - stripped of any ROM::Struct text.
      def name_from_object(class_name)
        if class_name.match?(/ROM::Struct/)
          r = Regexp.new(/ROM::Struct\[(?<klass>.+)\]/)
          r.match(class_name)[:klass]
        else
          class_name
        end
      end
    end
  end
end
