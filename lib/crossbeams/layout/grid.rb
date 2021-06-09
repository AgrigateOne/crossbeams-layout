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
        caption = options[:caption]
        renderer = Renderer::Grid.new(grid_id, url, caption, options)
        renderer.render
      end
    end
  end
end
