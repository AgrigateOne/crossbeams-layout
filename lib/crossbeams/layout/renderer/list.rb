# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a hidden Field.
      class List < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          attrs = [] # For class, prompt etc...
          attrs << "class=\"cbl-input #{@field_config[:class]}\""
          <<-HTML
          <div class="#{div_class}">#{hint_text}
            <ol #{attrs.join(' ')} id="#{@page_config.name}_#{@field_name}">
            #{item_renders}
            </ol>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
          </div>
          HTML
        end

        private

        def item_renders
          return '' if @field_config[:items].nil? || @field_config[:items].empty?
          items = @field_config[:items].first.is_a?(Array) ? @field_config[:items].map(&:first) : @field_config[:items]
          items.map do |text|
            %(<li>#{text}</li>)
          end.join("\n")
        end
      end
    end
  end
end
