module Crossbeams
  module Layout

    class PageConfig
      attr_reader :form_object, :name, :options
      def initialize(options={})
        @form_object = options.delete(:form_object)# || blank_object?
        @name        = options.delete(:name) || 'jmt'
        @options     = options
      end

      def form_object=(obj)
        @form_object = obj
        @name        = (obj.class.name || 'jmt').downcase if name == 'jmt'
      end

    end

  end

end
