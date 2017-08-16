# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Row is a container for Columns.
    class Row
      include PageNode
      attr_reader :sequence, :nodes, :page_config

      def initialize(page_config, section_sequence, sequence)
        @section_sequence = section_sequence
        @sequence         = sequence
        @nodes            = []
        @page_config      = page_config
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def self.make_row(page_config, section_sequence, sequence)
        new(page_config, section_sequence, sequence)
      end

      def column(column_size = :full)
        column = Column.new(page_config, column_size, sequence, nodes.length + 1)
        yield column
        @nodes << column
      end

      def add_node(node)
        @nodes << node
      end

      # Use dependency-injection to wrap the render so different CSS libraries can be used for the grid.
      # Use DRY-RB? or something simpler? Russ Olsen?
      def render
        if invisible?
          ''
        else
          col_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Col -->\n")
          <<-EOS
          <div class="crossbeams-row">
            #{col_renders}
          </div>
          EOS
        end
      end
    end
  end
end
