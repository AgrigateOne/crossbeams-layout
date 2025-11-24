# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard label
    class DashboardLabel
      SC = StylesConfig

      def initialize(label, opts = {})
        @label = label
        @opts = opts
        @nodes = []
      end

      def render
        centre = @opts[:center] && !@opts[:banner] ? ' text-center' : ''
        <<-HTML
          <div class="flex flex-col">
            <span class="#{font_weight}#{centre}#{size}#{colour}#{banner}">#{@label}</span>
          </div>
        HTML
      end

      def banner
        return '' unless @opts[:banner]

        col = case @opts[:banner]
              when :blue
                'bg-blue-200 text-blue-600'
              when :purple
                'bg-purple-200 text-purple-600'
              end
        " p-2 text-center #{col}"
      end

      def size
        case @opts[:size]
        when :large
          ' text-5xl'
        when :big
          ' text-3xl'
        else
          ''
        end
      end

      def colour
        case @opts[:colour]
        when :orange
          ' text-orange-600'
        else
          ''
        end
      end

      def font_weight
        return 'font-medium' unless @opts[:font_weight]

        'font-normal'
      end
    end
  end
end
