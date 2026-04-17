# frozen_string_literal: true

require 'securerandom'

module Crossbeams
  module Layout
    # Render a Vega/Vega-Lite chart in the Page.
    #
    # This component integrates with the vega-ruby gem to display interactive
    # charts. The chart specification can be provided as a Hash, a JSON string,
    # or a Vega::LiteChart/Vega::Chart object from the vega-ruby gem.
    #
    # == Host Application Requirements
    #
    # The host application must include the following JavaScript libraries:
    # - vega (https://vega.github.io/vega/)
    # - vega-lite (https://vega.github.io/vega-lite/)
    # - vega-embed (https://github.com/vega/vega-embed)
    #
    # Additionally, the host must provide a global `crossbeamsCharts` object:
    #
    #   window.crossbeamsCharts = {
    #     render: function(elementId, spec, options) {
    #       vegaEmbed('#' + elementId, spec, options).catch(console.error);
    #     }
    #   };
    #
    # == Usage
    #
    #   page.add_chart(
    #     { data: { values: data }, mark: 'bar', encoding: { ... } },
    #     id: 'my-chart',
    #     height: 400,
    #     caption: 'Sales by Month'
    #   )
    #
    # Or with vega-ruby:
    #
    #   chart = Vega.lite.data(data).mark('bar').encoding(x: {...}, y: {...})
    #   page.add_chart(chart, id: 'my-chart')
    #
    class Chart
      attr_reader :chart_id, :spec, :page_config, :options

      def initialize(page_config, spec, options = {})
        @page_config = page_config
        @spec = spec
        @chart_id = options[:id] || "chart-#{SecureRandom.hex(4)}"
        @options = options
        @renderer = Renderer::Chart.new(@chart_id, spec, options)
      end

      # Is this node invisible?
      #
      # @return [boolean] - true if it should not be rendered at all, else false.
      def invisible?
        false
      end

      # Is this node hidden?
      #
      # @return [boolean] - true if it should be rendered as hidden, else false.
      def hidden?
        false
      end

      # Render this node as HTML.
      #
      # @return [String] - HTML representation of this node.
      def render
        @renderer.render
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      #
      # @return [boolean]
      def dom_loaded?
        @renderer.dom_loaded?
      end

      # DOM loaded javascript snippets.
      #
      # @return [Array<String>]
      def list_dom_loaded
        @renderer.list_dom_loaded
      end
    end
  end
end
