# frozen_string_literal: true

module Crossbeams
  module Layout
    # A table of data.
    class Table # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :columns, :rows, :options

      BUILT_IN_TRANSFORMERS = {
        integer: ->(a) { a && format('%d', a) },
        decimal: ->(a) { a && format('%.2f', a) },
        decimal_4: ->(a) { a && format('%.4f', a) } # rubocop:disable Naming/VariableNumber
      }.freeze

      def initialize(page_config, rows, columns, options = {})
        @page_config = page_config
        @columns     = columns || []
        @rows        = Array(rows)
        @columns     = columns_from_rows if @columns.empty?
        @options     = { has_columns: !@columns.empty? }.merge(options)
        table_classes(options[:no_border])
        @nodes       = []
      end

      def table_classes(no_border)
        @tc_div = no_border ? :table_div_no_b : :table_div
        @tc_th = no_border ? :table_th_no_b : :table_th
        @tc_td = no_border ? :table_td_no_b : :table_td
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
        if rows.empty?
          return "#{dom_start}#{dom_end}" if options[:dom_id]

          return ''
        end

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
            <tr class="#{SC.css_class(:table_row_odd)}">
              #{format_column_headers.join}
            </tr>
          </thead>
        HTML
      end

      def standard_render
        <<~HTML
          #{dom_start}#{table_caption}<table class="#{SC.css_class(:table)}">
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

        " mt-#{options[:top_margin]}"
      end

      def left_margin
        return '' unless options[:left_margin]
        raise ArgumentError, 'Left margin must be in the range 0..7' unless (0..7).cover?(options[:left_margin])

        " ml-#{options[:left_margin]}"
      end

      def table_caption
        return '' unless options[:caption]

        %(<div class="#{SC.css_class(:table_caption)}">#{options[:caption]}</div>)
      end

      def pivot_render
        raise ArgumentError, 'Pivot must have column headers' unless options[:has_columns]

        elements = pivot_rows
        <<~HTML
          #{dom_start}#{table_caption}<table class="#{SC.css_class(:table)}">
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
        dom_id = %( id="#{options[:dom_id]}") if options[:dom_id]

        %(<div#{dom_id} class="#{SC.css_class(@tc_div)}#{top_margin}#{left_margin}">)
      end

      def dom_end
        '</div>'
      end

      def pivot_strings(elements)
        out = []
        cnt = elements.length - 1
        elements.each_with_index do |elem, i|
          out << pivot_row(elem, i, cnt == i).join
        end
        out
      end

      def pivot_row(elem, index, last) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        css_class = if last
                      index.odd? ? :table_row_even_last : :table_row_odd_last
                    else
                      index.odd? ? :table_row_even : :table_row_odd
                    end
        this_row = [%(<tr class="#{SC.css_class(css_class)}">)]
        col = nil
        lc = elem.length - 1

        elem.each_with_index do |e, i|
          col = e if i.zero?
          this_row << if i.zero?
                        %(<th class="#{SC.css_class(@tc_th)}" align='left'>#{header_translate[e] || e.to_s.capitalize.tr('_', ' ')}</th>)
                      else
                        %(<td class="#{SC.css_class(lc == i ? :table_td_last : @tc_td)}#{classes_for_col(col, e)}"#{attr_for_col(col)} style='min-width:3rem'>#{e || '&nbsp;'}</td>)
                      end
        end
        this_row << '</tr>'
      end

      def header_translate
        @header_translate ||= options[:header_captions] || {}
      end

      def format_column_headers
        columns.map { |c| %(<th class="#{SC.css_class(@tc_th)}">#{header_translate[c] || c.to_s.capitalize.tr('_', ' ')}</th>) }
      end

      def strings # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        odd = true
        cnt = rows.length - 1
        rows.map.with_index do |row, index|
          tr_css = if cnt == index
                     odd ? SC.css_class(:table_row_odd_last) : SC.css_class(:table_row_even_last)
                   else
                     odd ? SC.css_class(:table_row_odd) : SC.css_class(:table_row_even)
                   end
          odd = !odd
          if columns.empty?
            lc = row.length - 1
            %(<tr class="#{tr_css}">#{row.map.with_index { |r, i| %(<td class="#{SC.css_class(lc == i ? :table_td_last : @tc_td)}"#{r.is_a?(Numeric) ? ' align="right"' : ''}>#{r}</td>) }.join}</tr>)
          else
            lc = columns.length - 1
            %(<tr class="#{tr_css}">#{columns.map.with_index { |c, i| %(<td class="#{SC.css_class(lc == i ? :table_td_last : @tc_td)}#{classes_for_col(c, row[c])}"#{attr_for_col(c)}>#{transform_cell(c, row[c])}</td>) }.join}</tr>)
          end
        end
      end

      def classes_for_col(col, val)
        class_calc = options.dig(:cell_classes, col)
        return '' if class_calc.nil?

        " #{class_calc.call(val)}"
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
