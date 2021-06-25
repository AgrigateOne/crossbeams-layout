# frozen_string_literal: true

module Crossbeams
  module Layout
    # Render a data grid in the Page.
    class Grid
      include PageNode
      attr_reader :grid_id, :url, :page_config, :options

      def initialize(page_config, grid_id, url, options = {})
        @grid_id     = grid_id
        @url         = url
        @page_config = page_config
        @options     = options
        @nodes       = []

        return if options[:for_print]

        caption = options[:caption]
        @screen_renderer = Renderer::Grid.new(grid_id, url, caption, options)
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        if options[:for_print]
          render_for_print
        else
          render_for_screen
        end
      end

      def render_for_print
        <<-HTML
        <div id="#{grid_id}" style="height: 100%;" class="ag-theme-balham" data-gridurl="#{page_config.options[:grid_url]}" data-grid="grid" data-grid-print="forPrint"></div>
        HTML
      end

      def render_for_screen
        @screen_renderer.render
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      def dom_loaded?
        return false if options[:for_print]

        @screen_renderer.dom_loaded?
      end

      # DOM loaded javascript snippets.
      def list_dom_loaded
        return false if options[:for_print]

        @screen_renderer.list_dom_loaded
      end
    end
  end
end
