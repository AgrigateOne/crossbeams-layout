# frozen_string_literal: true

module Crossbeams
  module Layout
    # Base chart component
    class Chart
      SC = StylesConfig

      def initialize(options)
        @dom_id = options.fetch(:dom_id, "chart-#{SecureRandom.hex(4)}")
        @dom_loaded = []
        @title = options.fetch(:title, '')
        @data = nil
        @mark = nil
        @encoding = nil
        @show_source = options.fetch(:show_soource, false)
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      def dom_loaded?
        !@dom_loaded.empty?
      end

      # DOM loaded javascript snippets.
      def list_dom_loaded
        @dom_loaded
      end

      def invisible?
        false
      end

      def render
        @dom_loaded << "crossbeamsCharts.render('#{@dom_id}', #{spec_json}, #{opts});"

        %(<div id="#{@dom_id}" class="m-2" style="width:100%;height:100%"></div>)
      end

      def filename
        return 'OnePackChart' if @title&.empty?

        # @title.gsub(' ', '_').gsub(%r{[^\s/\\*?:&"'<>|]}, '_')
        @title.gsub(' ', '_').gsub(%r{["'&^:|?*<>/]}, '')
      end

      def opts
        hs = { actions: { editor: false }, downloadFileName: filename } # dl filename default to some asect of the title?
        # downloadFileName
        unless @show_source
          hs[:actions][:source] = false
          hs[:actions][:compiled] = false
        end
        hs.to_json
      end

      def spec_json
        {
          '$schema': 'https://vega.github.io/schema/vega-lite/v6.json',
          'width': 'container',
          'description': @title,
          'title': @title,
          'data': @data,
          'mark': @mark,
          'encoding': @encoding,

          'config': {
            'arc': { 'fill': '#3366CC' },
            'area': { 'fill': '#3366CC' },
            'path': { 'stroke': '#3366CC' },
            'rect': { 'fill': '#3366CC' },
            'shape': { 'stroke': '#3366CC' },
            'symbol': { 'stroke': '#3366CC' },
            'circle': { 'fill': '#3366CC' },
            'background': '#fff',
            'padding': { 'top': 10, 'right': 10, 'bottom': 10, 'left': 10 },
            'style': {
              'guide-label': { 'font': 'Arial, sans-serif', 'fontSize': 14 },
              'guide-title': { 'font': 'Arial, sans-serif', 'fontSize': 14 },
              'group-title': { 'font': 'Arial, sans-serif', 'fontSize': 14 }
            },
            'title': {
              'font': 'Arial, sans-serif',
              'fontSize': 16,
              'fontWeight': 'bold',
              'dy': -3,
              'anchor': 'start'
            },
            'axis': {
              'gridColor': '#ccc',
              'tickColor': '#ccc',
              'domain': false,
              'grid': true
            },
            'range': {
              'category': [
                '#2BBBFF',
                '#B0DC36',
                '#FCB323',
                '#818CF8',
                '#007FFF',
                '#739C14',
                '#DA6B05',
                '#4F46E5'
              ],
              'heatmap': ['#c6dafc', '#5e97f6', '#2a56c6']
            }
          }
        }.to_json
      end
      #     'range': {
      #       'category': [
      #         '#0A2D61',
      #         '#0067FF',
      #         '#B0DC36',
      #         '#D4F0FF'
      #       ],
      # 2BBBFF
      # B0DC36
      # FCB323
      # 818CF8
      #
      # 007FFF
      # 739C14
      # DA6B05
      # 4F46E5
      #
      # 0067FF
      # 5B8200
      # B54908
      # 4F46E5

      def human_string(str)
        str.to_s.gsub('_', ' ').capitalize
      end
    end

    # Donut charts
    class DonutChart < Chart
      def initialize(options)
        super

        @data = { 'values': options[:data] || [] }
        @mark = { 'type': 'arc', 'innerRadius': 90, 'tooltip': { 'content': 'encoding' } }
        @encoding = {
          'theta': { 'field': options[:q_field], 'type': 'quantitative' },
          'color': { 'field': options[:n_field], 'type': 'nominal', title: options[:n_title] || human_string(options[:n_field]) }
        }
      end
    end

    # Bar charts
    class BarChart < Chart
      def initialize(options) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        super

        @data = { 'values': options[:data] || [] }
        @mark = { type: 'bar', cornerRadiusEnd: 4, 'tooltip': { 'content': 'encoding' } }
        x_field = options[:x_field]
        y_field = options[:y_field]
        x_encoding = { field: x_field.to_s, type: options[:x_type] || 'nominal', axis: { labelAngle: 0 }, title: options[:x_title] || human_string(options[:x_field]) }
        y_encoding = { field: y_field.to_s, type: options[:y_type] || 'quantitative' }

        x_encoding, y_encoding = y_encoding, x_encoding if options[:horizontal]

        @encoding = { x: x_encoding, y: y_encoding }
        @encoding[:color] = color_encoding(options[:color_field]) if options[:color_field]
        @encoding[:xOffset] = { field: options[:color_field].to_s } if options[:color_field] && !options[:stacked]

        # @encoding = {
        #   'theta': { 'field': options[:q_field], 'type': 'quantitative' },
        #   'color': { 'field': options[:n_field], 'type': 'nominal' }
        # }
      end
    end
  end
end
