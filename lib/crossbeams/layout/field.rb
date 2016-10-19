module Crossbeams
  module Layout
    class Field
      attr_reader :name, :caption, :page_config

      def initialize(page_config, name, options = {})
        @name        = name
        @caption     = options[:caption] || name
        @page_config = page_config
      end

      def render
        <<-EOS
      <div class="field pure-control-group">
        <label for="#{page_config.name}_#{name}">#{caption}</label>
        <input type="text" value="#{page_config.form_object.send(name)}" name="#{page_config.name}[#{name}]" id="#{page_config.name}_#{name}">
      </div>
        EOS
      end
    end
  end
end
