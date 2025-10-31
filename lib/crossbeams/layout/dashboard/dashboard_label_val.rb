# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardLabelVal
      SC = StylesConfig

      def initialize(label, val, opts = {})
        @label = label
        @val = val
        @opts = opts
        @nodes = []
      end

      def render
        <<-HTML
          <div class="flex flex-#{@opts[:horizontal] ? 'row' : 'col'}">
            <span class="#{font_weight}">#{@label}</span>
            <span #{val_dom_id}class="#{text_colour}#{@opts[:horizontal] ? ' ml-2' : ''}">#{@val || '&nbsp;'}</span>
          </div>
        HTML
      end

      private

      def val_dom_id
        return '' unless @opts[:val_dom_id]

        %(id="#{@opts[:val_dom_id]}" )
      end

      def text_colour
        return SC.css_class(:text_error) if @opts[:val_colour] == :error
        return SC.css_class(:text_warning) if @opts[:val_colour] == :warning

        'text-blue-600'
      end

      def font_weight
        return 'font-medium' unless @opts[:font_weight]

        'font-normal'
      end
    end
  end
end
