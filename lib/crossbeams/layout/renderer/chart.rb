# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Vega/Vega-Lite chart.
      #
      # This renderer generates the HTML container and JavaScript initialization
      # for charts using the vega-ruby gem. The host application must include
      # the required JavaScript libraries (vega, vega-lite, vega-embed) and
      # provide a `crossbeamsCharts.render` function.
      class Chart < Base
        SC = StylesConfig

        def initialize(chart_id, spec, options = {})
          super()
          @chart_id = chart_id
          @spec = spec
          @options = options
          @width = options[:width]
          @height = options[:height]
          @caption = options[:caption]
          @embed_options = options[:embed_options] || {}

          add_chart_init
        end

        def render
          <<~HTML
            <div id="#{@chart_id}-wrapper" class="#{wrapper_classes}">
              #{render_caption}
              <div id="#{@chart_id}" class="#{container_classes}"#{dimensions_style} data-chart-spec='#{spec_json}'></div>
            </div>
          HTML
        end

        private

        def add_chart_init
          opts = @embed_options.to_json
          add_dom_loaded(<<~JS)
            crossbeamsCharts.render('#{@chart_id}', #{spec_json}, #{opts});
          JS
        end

        def spec_json
          @spec_json ||= extract_spec_json
        end

        def extract_spec_json
          case @spec
          when Hash
            @spec.to_json
          when String
            @spec
          else
            if @spec.respond_to?(:spec)
              @spec.spec.to_json
            else
              @spec.to_json
            end
          end
        end

        def wrapper_classes
          SC.css_class(:chart_wrapper)
        end

        def container_classes
          SC.css_class(:chart_container)
        end

        def dimensions_style
          styles = []
          styles << "width: #{normalize_dimension(@width)}" if @width
          styles << "height: #{normalize_dimension(@height)}" if @height
          return '' if styles.empty?

          %( style="#{styles.join('; ')}")
        end

        def normalize_dimension(value)
          return value if value.is_a?(String) && value.match?(/\D/)

          "#{value}px"
        end

        def render_caption
          return '' unless @caption

          %(<div class="#{SC.css_class(:chart_caption)}">#{@caption}</div>)
        end
      end
    end
  end
end
