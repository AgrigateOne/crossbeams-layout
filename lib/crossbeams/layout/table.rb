# frozen_string_literal: true

module Crossbeams
  module Layout
    # A table of data.
    class Table # rubocop:disable Metrics/ClassLength
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
        if options[:pivot] && @options[:pivot] == true
          pivot_render
        else
          standard_render
        end
      end

      private

      def head
        <<~HTML
          <thead>
            <tr>
              #{format_columns.join}
            </tr>
          </thead>
        HTML
      end

      def standard_render
        <<~HTML
          <table class="thinbordertable#{top_margin}">#{table_caption}
            #{head if @options[:has_columns]}
            <tbody>
              #{strings.join("\n")}
            </tbody>
          </table>
        HTML
      end

      def top_margin
        return '' unless options[:top_margin]
        raise ArgumentError, 'Top margin must be in the range 0..7' unless (0..7).cover?(options[:top_margin])
        " mt#{options[:top_margin]}"
      end

      def table_caption
        return '' unless options[:caption]
        "\n<caption>#{options[:caption]}</caption>"
      end

      def pivot_render
        raise ArgumentError, 'Pivot must have column headers' unless @options[:has_columns]

        elements = @columns.map { |c| [c, @rows.map { |row| row[c] }].flatten }
        <<~HTML
          <table class="thinbordertable#{top_margin}">#{table_caption}
            <tbody>
              #{pivot_strings(elements).join("\n")}
            </tbody>
          </table>
        HTML
      end

      def pivot_strings(elements)
        out = []
        elements.each do |elem|
          out << pivot_row(elem).join
        end
        out
      end

      def pivot_row(elem)
        this_row = ["<tr class='hover-row'>"]
        elem.each_with_index do |e, i|
          col = e if i.zero?
          this_row << if i.zero?
                        "<th align='right'>#{header_translate[e] || e.to_s.capitalize.tr('_', ' ')}</th>"
                      else
                        "<td#{attr_for_col(col)} #{classes_for_col(col, e)}>#{e || '&nbsp;'}</td>"
                      end
        end
        this_row << '</tr>'
      end

      def header_translate
        @header_translate ||= @options[:header_captions] || {}
      end

      def format_columns
        @columns.map { |c| "<th>#{header_translate[c] || c.to_s.capitalize.tr('_', ' ')}</th>" }
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
