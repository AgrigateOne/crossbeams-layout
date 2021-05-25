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
          validate_remove_item_url(field_config)
        end

        def render # rubocop:disable Metrics/AbcSize
          attrs = [] # For class, prompt etc...
          attrs << "class=\"cbl-input mt0 mr0 mb0 ml3 #{@field_config[:class]}#{scroll_class}#{bg_class}\""
          attrs << %(data-remove-item-url="#{@remove_item_url}") unless @remove_item_url.nil?
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <ol #{attrs.join(' ')} #{field_id}>
            #{item_renders}
            </ol>
            <label for="#{id_base}">#{@caption}#{error_state}#{hint_trigger}</label>
          </div>
          HTML
        end

        private

        def validate_remove_item_url(field_config)
          @remove_item_url = field_config[:remove_item_url]
          return if @remove_item_url.nil?

          raise ArgumentError, %(List "remove_item_url" must include "$:id$" token) unless @remove_item_url.include?('$:id$')
          raise ArgumentError, %(List items must be 2-D array if "remove_item_url" is provided) unless @field_config[:items].empty? || @field_config[:items].first.is_a?(Array)
        end

        def validate_scroll_height
          return if @field_config[:scroll_height].nil?

          raise ArgumentError, 'List: scroll_height can only be ":short" or ":medium"' unless %i[short medium].include?(@field_config[:scroll_height])
        end

        def bg_class
          return '' unless @field_config[:filled_background]

          ' bg-light-gray ba b--silver br2'
        end

        def scroll_class
          return '' unless @field_config[:scroll_height]

          validate_scroll_height
          " cbl-list-scroll-#{@field_config[:scroll_height]}"
        end

        def item_renders
          return '' if @field_config[:items].nil_or_empty?

          if @remove_item_url.nil?
            plain_item_renders
          else
            remove_item_renders
          end
        end

        def plain_item_renders
          items = @field_config[:items].first.is_a?(Array) ? @field_config[:items].map(&:first) : @field_config[:items]
          items.map do |text|
            %(<li>#{text}</li>)
          end.join("\n")
        end

        def remove_item_renders
          @field_config[:items].map do |text, id|
            %(<li data-item-id="#{id}">#{minus_icon(id)} #{text}</li>)
          end.join("\n")
        end

        def minus_icon(id)
          Icon.new(:minus, css_class: 'red pointer', attrs: [%(data-remove-item="#{id}")]).render
        end
      end
    end
  end
end
