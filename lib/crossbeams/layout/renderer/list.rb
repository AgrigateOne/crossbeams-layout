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
          attrs << "class=\"cbl-input ma0 #{@field_config[:class]}#{scroll_class}#{bg_class}\""
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <ol #{attrs.join(' ')} #{field_id}>
            #{item_renders}
            </ol>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
          </div>
          HTML
        end

        private

        def bg_class
          return '' unless @field_config[:filled_background]

          ' bg-light-gray ba b--silver br2'
        end

        def scroll_class
          return '' unless @field_config[:scroll_height]

          " cbl-list-scroll-#{@field_config[:scroll_height]}"
        end

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
