# frozen_string_literal: true

module Crossbeams
  module Layout
    # A table of data.
    class Table # rubocop:disable Metrics/ClassLength
      include PageNode
      attr_reader :columns, :rows, :options

      BUILT_IN_TRANSFORMERS = {
        integer: ->(a) { a && format('%d', a) },
        decimal: ->(a) { a && format('%.2f', a) },
        decimal_4: ->(a) { a && format('%.4f', a) }
      }.freeze

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
        return "#{dom_start}#{dom_end}" if rows.empty?

        if options[:pivot] && options[:pivot] == true
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
              #{format_column_headers.join}
            </tr>
          </thead>
        HTML
      end

      def standard_render
        <<~HTML
          #{dom_start}<table class="thinbordertable#{top_margin}">#{table_caption}
            #{head if options[:has_columns]}
            <tbody>
              #{strings.join("\n")}
            </tbody>
          </table>#{dom_end}
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
        raise ArgumentError, 'Pivot must have column headers' unless options[:has_columns]

        elements = pivot_rows
        <<~HTML
          #{dom_start}<table class="thinbordertable#{top_margin}">#{table_caption}
            <tbody>
              #{pivot_strings(elements).join("\n")}
            </tbody>
          </table>#{dom_end}
        HTML
      end

      def pivot_rows
        columns.map do |col|
          [
            col,
            rows.map { |row| transform_cell(col, row[col]) }
          ].flatten
        end
      end

      def dom_start
        return '' unless options[:dom_id]

        %(<div id="#{options[:dom_id]}">)
      end

      def dom_end
        return '' unless options[:dom_id]

        '</div>'
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
        col = nil
        elem.each_with_index do |e, i|
          col = e if i.zero?
          this_row << if i.zero?
                        "<th align='right'>#{header_translate[e] || e.to_s.capitalize.tr('_', ' ')}</th>"
                      else
                        "<td#{attr_for_col(col)} #{classes_for_col(col, e)} style='min-width:3rem'>#{e || '&nbsp;'}</td>"
                      end
        end
        this_row << '</tr>'
      end

      def header_translate
        @header_translate ||= options[:header_captions] || {}
      end

      def format_column_headers
        columns.map { |c| "<th>#{header_translate[c] || c.to_s.capitalize.tr('_', ' ')}</th>" }
      end

      def strings
        rows.map do |row|
          if columns.empty?
            "<tr class='hover-row'>#{row.map { |r| "<td#{r.is_a?(Numeric) ? ' align="right"' : ''}>#{r}</td>" }.join}</tr>"
          else
            "<tr class='hover-row'>#{columns.map { |c| "<td#{attr_for_col(c)}#{classes_for_col(c, row[c])}>#{transform_cell(c, row[c])}</td>" }.join}</tr>"
          end
        end
      end

      def classes_for_col(col, val)
        class_calc = options.dig(:cell_classes, col)
        return '' if class_calc.nil?

        " class='#{class_calc.call(val)}'"
      end

      def transform_cell(col, val)
        transformer = options.dig(:cell_transformers, col)
        return val if transformer.nil?
        return transformer.call(val) if transformer.respond_to?(:call)

        BUILT_IN_TRANSFORMERS[transformer].call(val)
      end

      def attr_for_col(col)
        alignment = options.dig(:alignment, col)
        return '' if alignment.nil?

        %( align="#{alignment}")
      end

      def columns_from_rows
        return [] if rows.empty?
        return [] unless rows.first.is_a?(Hash)

        rows.first.keys
      end
    end
  end
end
