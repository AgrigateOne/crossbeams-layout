# frozen_string_literal: true

module Crossbeams
  module Layout
    # A page can optionally contain one or more sections.
    class Section
      include PageNode
      attr_accessor :caption, :hide_caption
      attr_reader :sequence, :nodes, :page_config

      def initialize(page_config, sequence)
        @caption      = 'Section'
        @sequence     = sequence
        @nodes        = []
        @page_config  = page_config
        @hide_caption = true
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form
        @nodes << form
      end

      def row
        row = Row.new(page_config, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      def add_grid(grid_id, url, options = {})
        @nodes << Grid.new(page_config, grid_id, url, options)
      end

      def add_text(text, opts = {})
        @nodes << Text.new(page_config, text, opts)
      end

      def add_address(addresses, opts = {})
        @nodes << Address.new(page_config, addresses, opts)
      end

      # Add a control (button, link) to the page.
      #
      # @return [void]
      def add_control(page_control_definition)
        @nodes << Link.new(page_control_definition) if page_control_definition[:control_type] == :link
      end

      def render
        row_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Row -->\n")
        <<-HTML
      <section id="section-#{sequence}" class="crossbeams_layout">
      #{render_caption}
        #{row_renders}
      </section>
        HTML
      end

      private

      def render_caption
        return '' if hide_caption
        "<h2>#{caption}</h2>"
      end
    end
  end
end
