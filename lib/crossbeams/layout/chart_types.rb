# frozen_string_literal: true

module Crossbeams
  module Layout
    # Factory methods for creating common chart type specifications.
    # These methods generate Vega-Lite specs with sensible defaults
    # and consistent styling across the application.
    module ChartTypes # rubocop:disable Metrics/ModuleLength
      # Modern color palette matching crossbeams-layout Tailwind theme.
      # Based on ocean (primary) and slate (secondary) color families.
      COLOR_PALETTE = [
        '#0e7490', # ocean-700 (primary)
        '#0891b2', # cyan-600
        '#0d9488', # teal-600
        '#059669', # emerald-600
        '#0284c7', # sky-600
        '#6366f1', # indigo-500
        '#8b5cf6', # violet-500
        '#64748b', # slate-500
        '#f59e0b', # amber-500
        '#ef4444'  # red-500
      ].freeze

      class << self
        # Build a bar chart spec.
        #
        # @param data [Array<Hash>] Array of data points
        # @param x_field [Symbol, String] Field name for x-axis (categories)
        # @param y_field [Symbol, String] Field name for y-axis (values)
        # @param options [Hash] Additional options
        # @option options [String] :title Chart title
        # @option options [Symbol, String] :color_field Field for color grouping
        # @option options [Boolean] :horizontal Render as horizontal bar chart
        # @option options [Boolean] :stacked Stack bars when using color_field
        # @return [Hash] Vega-Lite specification
        def bar_chart(data, x_field:, y_field:, **options)
          x_encoding = { field: x_field.to_s, type: options[:x_type] || 'nominal', axis: { labelAngle: 0 } }
          y_encoding = { field: y_field.to_s, type: options[:y_type] || 'quantitative' }

          if options[:horizontal]
            x_encoding, y_encoding = y_encoding, x_encoding
          end

          encoding = { x: x_encoding, y: y_encoding }
          encoding[:color] = color_encoding(options[:color_field]) if options[:color_field]
          encoding[:xOffset] = { field: options[:color_field].to_s } if options[:color_field] && !options[:stacked]

          mark = { type: 'bar', cornerRadiusEnd: 4 }
          build_spec(data, mark, encoding, options)
        end

        # Build a line chart spec.
        #
        # @param data [Array<Hash>] Array of data points
        # @param x_field [Symbol, String] Field name for x-axis
        # @param y_field [Symbol, String] Field name for y-axis
        # @param options [Hash] Additional options
        # @option options [String] :title Chart title
        # @option options [Symbol, String] :color_field Field for color/series grouping
        # @option options [Boolean] :show_points Show data points on line
        # @option options [String] :x_type Type for x-axis ('temporal', 'ordinal', 'quantitative')
        # @return [Hash] Vega-Lite specification
        def line_chart(data, x_field:, y_field:, **options)
          encoding = {
            x: { field: x_field.to_s, type: options[:x_type] || 'ordinal' },
            y: { field: y_field.to_s, type: options[:y_type] || 'quantitative' }
          }
          encoding[:color] = color_encoding(options[:color_field]) if options[:color_field]

          mark = {
            type: 'line',
            strokeWidth: 2,
            strokeCap: 'round',
            strokeJoin: 'round'
          }
          mark[:point] = { filled: true, size: 60 } if options[:show_points]

          build_spec(data, mark, encoding, options)
        end

        # Build a pie chart spec.
        #
        # @param data [Array<Hash>] Array of data points
        # @param value_field [Symbol, String] Field name for slice values
        # @param category_field [Symbol, String] Field name for slice categories
        # @param options [Hash] Additional options
        # @option options [String] :title Chart title
        # @option options [Numeric] :inner_radius Inner radius for donut chart (0 for pie)
        # @return [Hash] Vega-Lite specification
        def pie_chart(data, value_field:, category_field:, **options)
          encoding = {
            theta: { field: value_field.to_s, type: 'quantitative' },
            color: color_encoding(category_field)
          }

          mark = {
            type: 'arc',
            padAngle: 0.02,
            stroke: '#ffffff',
            strokeWidth: 2
          }
          mark[:innerRadius] = options[:inner_radius] if options[:inner_radius]
          mark[:cornerRadius] = 4

          build_spec(data, mark, encoding, options)
        end

        # Build a donut chart spec (pie chart with inner radius).
        #
        # @param data [Array<Hash>] Array of data points
        # @param value_field [Symbol, String] Field name for slice values
        # @param category_field [Symbol, String] Field name for slice categories
        # @param options [Hash] Additional options
        # @return [Hash] Vega-Lite specification
        def donut_chart(data, value_field:, category_field:, **options)
          pie_chart(data, value_field: value_field, category_field: category_field, inner_radius: options[:inner_radius] || 50, **options)
        end

        # Build an area chart spec.
        #
        # @param data [Array<Hash>] Array of data points
        # @param x_field [Symbol, String] Field name for x-axis
        # @param y_field [Symbol, String] Field name for y-axis
        # @param options [Hash] Additional options
        # @option options [String] :title Chart title
        # @option options [Symbol, String] :color_field Field for color grouping (stacked area)
        # @option options [String] :x_type Type for x-axis ('temporal', 'ordinal', 'quantitative')
        # @return [Hash] Vega-Lite specification
        def area_chart(data, x_field:, y_field:, **options)
          encoding = {
            x: { field: x_field.to_s, type: options[:x_type] || 'ordinal' },
            y: { field: y_field.to_s, type: options[:y_type] || 'quantitative' }
          }
          encoding[:color] = color_encoding(options[:color_field]) if options[:color_field]

          mark = {
            type: 'area',
            line: true,
            opacity: 0.7,
            interpolate: 'monotone'
          }

          build_spec(data, mark, encoding, options)
        end

        # Build a scatter plot spec.
        #
        # @param data [Array<Hash>] Array of data points
        # @param x_field [Symbol, String] Field name for x-axis
        # @param y_field [Symbol, String] Field name for y-axis
        # @param options [Hash] Additional options
        # @option options [String] :title Chart title
        # @option options [Symbol, String] :color_field Field for color grouping
        # @option options [Symbol, String] :size_field Field for point size
        # @return [Hash] Vega-Lite specification
        def scatter_chart(data, x_field:, y_field:, **options)
          encoding = {
            x: { field: x_field.to_s, type: options[:x_type] || 'quantitative' },
            y: { field: y_field.to_s, type: options[:y_type] || 'quantitative' }
          }
          encoding[:color] = color_encoding(options[:color_field]) if options[:color_field]
          encoding[:size] = { field: options[:size_field].to_s, type: 'quantitative' } if options[:size_field]

          mark = {
            type: 'point',
            filled: true,
            size: 80,
            opacity: 0.8
          }

          build_spec(data, mark, encoding, options)
        end

        private

        def color_encoding(field)
          {
            field: field.to_s,
            type: 'nominal',
            scale: { range: COLOR_PALETTE },
            legend: {
              labelFontSize: 12,
              titleFontSize: 12,
              symbolSize: 100
            }
          }
        end

        def build_spec(data, mark, encoding, options) # rubocop:disable Metrics/AbcSize
          mark_config = if mark.is_a?(Hash)
                          mark.merge(tooltip: true)
                        else
                          { type: mark, tooltip: true }
                        end

          spec = {
            '$schema' => 'https://vega.github.io/schema/vega-lite/v5.json',
            'data' => { 'values' => data },
            'mark' => stringify_keys(mark_config),
            'encoding' => stringify_keys(encoding),
            'config' => chart_config
          }

          spec['title'] = title_config(options[:title]) if options[:title]
          spec['width'] = 'container' unless options[:width]
          spec['height'] = options[:chart_height] if options[:chart_height]

          spec
        end

        def chart_config
          {
            'background' => 'transparent',
            'font' => 'system-ui, -apple-system, sans-serif',
            'axis' => {
              'labelColor' => '#64748b',
              'labelFontSize' => 11,
              'titleColor' => '#334155',
              'titleFontSize' => 12,
              'titleFontWeight' => 500,
              'gridColor' => '#e2e8f0',
              'gridOpacity' => 0.8,
              'domainColor' => '#cbd5e1',
              'tickColor' => '#cbd5e1'
            },
            'legend' => {
              'labelColor' => '#475569',
              'labelFontSize' => 11,
              'titleColor' => '#334155',
              'titleFontSize' => 12,
              'titleFontWeight' => 500,
              'symbolStrokeWidth' => 0
            },
            'view' => {
              'stroke' => 'transparent'
            },
            'range' => {
              'category' => COLOR_PALETTE
            },
            'bar' => {
              'cornerRadiusEnd' => 4,
              'continuousBandSize' => 20
            },
            'arc' => {
              'stroke' => '#ffffff',
              'strokeWidth' => 2
            },
            'line' => {
              'strokeWidth' => 2,
              'strokeCap' => 'round'
            },
            'point' => {
              'filled' => true,
              'size' => 60
            },
            'area' => {
              'opacity' => 0.7
            }
          }
        end

        def title_config(title_text)
          {
            'text' => title_text,
            'anchor' => 'start',
            'fontSize' => 14,
            'fontWeight' => 600,
            'color' => '#1e293b',
            'offset' => 12
          }
        end

        def stringify_keys(hash)
          hash.transform_keys(&:to_s).transform_values do |v|
            v.is_a?(Hash) ? stringify_keys(v) : v
          end
        end
      end
    end
  end
end
