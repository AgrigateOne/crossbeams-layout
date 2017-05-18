module Crossbeams
  module Layout
    # A page can optionally contain one or more sections.
    class Section
      include PageNode
      attr_accessor :caption
      attr_reader :sequence, :nodes, :page_config

      def initialize(page_config, sequence)
        @caption     = 'Section'
        @sequence    = sequence
        @nodes       = []
        @page_config = page_config
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

      def render
        row_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Row -->\n")
        <<-EOS
      <section id="section-#{sequence}" class="crossbeams_layout">
      <h2>#{caption}</h2>
        #{row_renders}
      </section>
        EOS
      end
    end
  end
end
