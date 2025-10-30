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
            <span #{val_dom_id}class="text-blue-600#{@opts[:horizontal] ? ' ml-2' : ''}">#{@val || '&nbsp;'}</span>
          </div>
        HTML
      end

      private

      def val_dom_id
        return '' unless @opts[:val_dom_id]

        %(id="#{@opts[:val_dom_id]}" )
      end

      def font_weight
        return 'font-medium' unless @opts[:font_weight]

        'font-normal'
      end
    end
  end
end
