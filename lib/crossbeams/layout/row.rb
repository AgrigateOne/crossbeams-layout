# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Row is a container for Columns.
    class Row
      extend MethodBuilder

      build_methods_for :csrf

      attr_reader :sequence, :nodes, :page_config

      def initialize(page_config, section_sequence, sequence)
        @section_sequence = section_sequence
        @sequence         = sequence
        @nodes            = []
        @page_config      = page_config
        @row_width        = :standard
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

      # Render a blank column within a row to force another column in the row to half-size.
      def blank_column
        blank_col = '<div class="crossbeams-col"><!-- BLANK COL --></div>'
        @nodes << OpenStruct.new(render: blank_col)
      end

      def add_node(node)
        @nodes << node
      end

      def fit_width!
        @row_width = :full
      end

      # Use dependency-injection to wrap the render so different CSS libraries can be used for the grid.
      # Use DRY-RB? or something simpler? Russ Olsen?
      def render
        if invisible?
          ''
        else
          col_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Col -->\n")
          <<-HTML
          <div class="#{row_class}">
            #{col_renders}
          </div>
          HTML
        end
      end

      def row_class
        @row_width == :standard ? 'crossbeams-row' : 'crossbeams-row-wide'
      end
    end
  end
end
