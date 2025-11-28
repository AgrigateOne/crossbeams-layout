# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a hidden Field.
      class List < Base
        SC = StylesConfig

        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
          validate_remove_item_url(field_config)
        end

        def render
          attrs = [] # For class, prompt etc...
          attrs << %(class="#{SC.css_class(:ol)} ml-3 #{@field_config[:class]}#{scroll_class}#{bg_class}")
          attrs << %(data-remove-item-url="#{@remove_item_url}") unless @remove_item_url.nil?

          <<-HTML
          <div #{wrapper_id} class="#{div_class}#{wrapper_visibility}">#{hint_text}
            #{label_render(id_base, @caption)}
            <ol #{attrs.join(' ')} #{field_id}>
            #{item_renders}
            </ol>
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

          # ' bg-light-gray ba b--silver br2'
          ' bg-slate-200 border border-slate-600 rounded py-1'
        end

        def scroll_class
          return '' unless @field_config[:scroll_height]

          validate_scroll_height
          # " cbl-list-scroll-#{@field_config[:scroll_height]}"
          return 'h-20 overflow-y-auto' if @options[:scroll_height] == :short

          'h-44 overflow-y-auto'
        end

        def item_renders
          return '' if @field_config[:items].nil? || @field_config[:items].empty?

          if @remove_item_url.nil?
            plain_item_renders
          else
            remove_item_renders
          end
        end

        def plain_item_renders
          items = @field_config[:items].first.is_a?(Array) ? @field_config[:items].map(&:first) : @field_config[:items]
          items.map do |text|
            %(<li class="#{SC.css_class(:li)}">#{text}</li>)
          end.join("\n")
        end

        def remove_item_renders
          @field_config[:items].map do |text, id|
            %(<li class="#{SC.css_class(:li)}" title="Remove this item" data-item-id="#{id}">#{remove_icon(id)} #{text}</li>)
          end.join("\n")
        end

        def remove_icon(id)
          Icon.new(:remove, css_class: 'text-ocean-700 cursor-pointer inline', attrs: [%(data-remove-item="#{id}")]).render
        end
      end
    end
  end
end
