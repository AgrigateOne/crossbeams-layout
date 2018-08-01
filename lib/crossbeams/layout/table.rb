# frozen_string_literal: true

module Crossbeams
  module Layout
    # A table of data.
    class Table
      include PageNode
      attr_reader :columns, :rows, :options

      def initialize(page_config, rows, columns, options = {})
        @page_config = page_config
        @columns     = columns || []
        @rows        = Array(rows)
        @columns     = columns_from_rows if @columns.empty?
        @options     = { has_columns: !@columns.empty? }.merge(options)
        @nodes       = []
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

      # Render this node as HTML link.
      #
      # @return [string] - HTML representation of this node.
      def render
        return '' if rows.empty?
        <<~HTML
          <table class="thinbordertable">
            #{head if @options[:has_columns]}
            <tbody>
              #{strings.join("\n")}
            </tbody>
          </table>
        HTML
      end

      private

      def head
        <<~HTML
          <thead>
            <tr>
              #{format_columns}
            </tr>
          </thead>
        HTML
      end

      def format_columns
        @columns.map { |c| "<th>#{c}</th>" }.join
      end

      def strings
        @rows.map do |row|
          if @columns.empty?
            "<tr class='hover-row'>#{row.map { |r| "<td>#{r}</td>" }.join}</tr>"
          else
            "<tr class='hover-row'>#{@columns.map { |c| "<td#{attr_for_col(c)} #{classes_for_col(c, row[c])}>#{row[c]}</td>" }.join}</tr>"
          end
        end
      end

      def classes_for_col(col, val)
        if @options[:cell_classes] && @options[:cell_classes][col]
          "class='#{@options[:cell_classes][col].call(val)}'"
        else
          ''
        end
      end

      def attr_for_col(col)
        if @options[:alignment] && @options[:alignment][col]
          %( align="#{@options[:alignment][col]}")
        else
          ' '
        end
      end

      def columns_from_rows
        return [] if @rows.empty?
        return [] unless @rows.first.is_a?(Hash)
        @rows.first.keys
      end
    end
  end
end
