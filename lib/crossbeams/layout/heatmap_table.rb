# frozen_string_literal: true

module Crossbeams
  module Layout
    # Discrete heatmap component for use in LayoutGrid dashboards
    class HeatmapTable # rubocop:disable Metrics/ClassLength
      attr_reader :title, :human_numbers, :data, :row_height, :edge_col_width, :col_width, :last_row, :width, :img_width, :startx, :height, :bands, :zero_as

      SC = StylesConfig

      HEATS = {
        0 => '#F9FBFC',
        1 => '#EFF3F8',
        2 => '#E5EDF5',
        3 => '#C3D5E8',
        4 => '#8CAFD3',
        5 => '#719CC6',
        6 => '#528ABD',
        7 => '#296CAE',
        8 => '#1F64A8',
        max: '#0067FF',
        other: '#FFF'
      }.freeze
      CELL_CLASS = 'cell-text'
      CELL_DARK = 'cell-dark'

      def initialize(data, options = {})
        @title = options.fetch(:title, 'Heatmap')
        @human_numbers = options.fetch(:human_numbers, false)
        @data = data
        @row_height = 40
        @edge_col_width = 80
        @col_width = 64
        @zero_as = options[:zero_as]
        @last_row = data.length - 1
        @row_title = options[:row_title] # y_title
        @col_title = options[:col_title] # x_title
        @cell_title = options[:cell_title] || 'Value' # cell_title
      end

      def invisible?
        false
      end

      def render
        analyse_data

        ar = []
        ar << start_image
        ar += render_data
        ar << end_image
        <<~HTML
          <div data-heatmap="Y" class="m-2 overflow-x-scroll">
            #{ar.join("\n")}
          </div>
        HTML
      end

      def self.prepare_table_from_data(data, exclude_zero_total_rows: true, order_by: :total_desc) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        o = OpenStruct.new(row_title: nil,
                           row_agg_title: 'TOTAL',
                           foot_title: 'TOTAL',
                           row_key: nil,
                           col_key: nil,
                           val_key: nil,
                           agg_func: :sum,
                           col_fmt: nil,
                           row_sort_func: nil,
                           sort_by: ->(c) { c == 'None' ? 0 : c.to_i })
        yield o

        hs = {}
        gtot = BigDecimal('0')
        data.each do |r|
          hs[r[o.row_key]] ||= {}
          hs[r[o.row_key]][r[o.col_key]] = r[o.val_key]
          gtot += r[o.val_key] unless r[o.val_key].nil?
        end
        colset = Set.new
        data.each { |a| colset << a[o.col_key] }
        cols = colset.sort_by { |c| o.sort_by.call(c) }.to_a
        cnt = cols.length

        par = [[o.row_title || 'Row'] + cols.map { |c| o.col_fmt ? o.col_fmt.call(c) : c } + [o.row_agg_title || 'TOTAL']]
        ar = []
        coltot = Hash[cols.zip([0.0] * cols.length)]
        hs.keys.sort.each do |row_key|
          ftot = 0.0
          rec = [row_key] + cols.map do |c|
            ftot += hs[row_key][c] if hs[row_key][c]
            coltot[c] += hs[row_key][c] if hs[row_key][c]
            hs[row_key][c]
          end + row_total(ftot, cnt, gtot, o)
          ar << rec unless exclude_zero_total_rows && ftot.zero?
        end

        par += case order_by
               when :total_asc
                 ar.sort_by { |r| r[1...-1].sum { |a| a.nil? ? 0 : a } }
               when :row
                 if o.row_sort_func
                   ar.sort_by { |r| o.row_sort_func.call(r[0]) }
                 else
                   ar
                 end
               else # :total_desc
                 ar.sort_by { |r| 1 - r[1...-1].sum { |a| a.nil? ? 0 : a } }
               end
        par << [o.foot_title || 'TOTAL'] + cols.map { |c| coltot[c] } + grand_total(gtot, cnt, o)
        par
      end

      def self.row_total(ftot, cnt, gtot, opts)
        case opts.agg_func
        when :sum
          [ftot]
        when :avg_perc
          [ftot.zero? ? '0.00%' : format('%.2f%%', (ftot / cnt) / gtot * 100.0)]
        when :avg
          [ftot.zero? ? '0.00' : format('%.2f', ftot / cnt)]
        else
          []
        end
      end

      def self.grand_total(gtot, cnt, opts)
        case opts.agg_func
        when :sum
          [gtot]
        when :avg_perc
          [format('%.1f%%', ((gtot / cnt) / gtot) * 100.0)]
        when :avg
          [format('%.1f', gtot / cnt)]
        else
          []
        end
      end

      private_class_method :row_total, :grand_total

      private

      def render_data
        ar = []
        y_pos = 50
        data.each_with_index do |row, rdx|
          ar << case rdx
                when 0
                  build_header_row(row)
                when last_row
                  build_footer_row(row, y_pos)
                else
                  build_data_row(row, y_pos)
                end
          y_pos += row_height
        end
        ar
      end

      def x_for_current_index(idx)
        idx.zero? ? startx : startx + edge_col_width + ((idx - 1) * col_width)
      end

      def col_width_for_current_index(idx, len)
        idx.zero? || idx == len - 1 ? edge_col_width : col_width
      end

      def x_for_cell_text(x_pos, width)
        x_pos.zero? ? width / 2 : x_pos + (width / 2)
      end

      def y_for_cell_text(y_pos)
        y_pos + row_height / 2 + row_height / 10
      end

      def build_header_row(row) # rubocop:disable Metrics/AbcSize
        @row_title ||= row[0]
        @col_head_values = row.dup
        len = row.length
        ar = []
        ar << %(<rect x="#{startx}" y="50" rx="5" ry="5" width="#{width - edge_col_width}" height="#{row_height}" fill="#2563eb" stroke="#fff" stroke-width="1"/>)
        row.each_with_index do |col, idx|
          x = x_for_current_index(idx)
          w = col_width_for_current_index(idx, len)
          css_class = idx == len - 1 ? 'header-end' : 'header-text'
          ar << %(<text x="#{x_for_cell_text(x, w)}" y="#{y_for_cell_text(50)}" text-anchor="middle" class="#{css_class}">#{col}</text>)
        end
        ar.join("\n")
      end

      def build_footer_row(row, y_pos) # rubocop:disable Metrics/AbcSize
        len = row.length
        ar = []
        ar << %(<rect x="#{startx}" y="#{y_pos}" rx="5" ry="5" width="#{width}" height="#{row_height}" fill="#e5e7eb" stroke="#fff" stroke-width="1"/>)
        row.each_with_index do |col, idx|
          x = x_for_current_index(idx)
          w = col_width_for_current_index(idx, len)
          css_class = idx.zero? || idx == len - 1 ? 'total-name' : 'total-text'
          ar << %(<text x="#{x_for_cell_text(x, w)}" y="#{y_for_cell_text(y_pos)}" text-anchor="middle" class="#{css_class}">#{humanize_number(col)}</text>)
        end
        ar.join("\n")
      end

      def build_data_row(row, y_pos) # rubocop:disable Metrics/AbcSize
        len = row.length
        ar = []
        row.each_with_index do |col, idx|
          x = x_for_current_index(idx)
          w = col_width_for_current_index(idx, len)
          fill, css_class, heat = evaluate_col_fill(col, idx, idx == len - 1)
          aria = if idx.zero? || idx == len - 1
                   ''
                 else
                   %( aria-label="#{@row_title}: #{row[0]}; #{@cell_title}: #{col ? col.to_f : '-'}; #{@col_title}: #{@col_head_values[idx]}")
                 end
          ar << <<~SVG
            <g class="cell"#{aria}>
              <rect x="#{x}" y="#{y_pos}" rx="5" ry="5" width="#{w}" height="#{row_height}" fill="#{fill}" data-heat="#{heat}" class="cell-bg" stroke="#fff" stroke-width="1"/>
              <text x="#{x_for_cell_text(x, w)}" y="#{y_for_cell_text(y_pos)}" text-anchor="middle" pointer-events="none" class="#{css_class}">#{humanize_number(col)}</text>
            </g>
          SVG
        end
        ar.join("\n")
      end

      def evaluate_col_fill(col, idx, last_col) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        return ['#e5e7eb', CELL_CLASS, 'N'] if idx.zero? || last_col
        return [HEATS[:other], CELL_CLASS, 'N'] if col.nil?

        case BigDecimal(col)
        when bands[0]..bands[1]
          [HEATS[0], CELL_CLASS, 1]
        when bands[1]..bands[2]
          [HEATS[1], CELL_CLASS, 2]
        when bands[2]..bands[3]
          [HEATS[2], CELL_CLASS, 3]
        when bands[3]..bands[4]
          [HEATS[3], CELL_CLASS, 4]
        when bands[4]..bands[5]
          [HEATS[4], CELL_CLASS, 5]
        when bands[5]..bands[6]
          [HEATS[5], CELL_DARK, 6]
        when bands[6]..bands[7]
          [HEATS[6], CELL_DARK, 7]
        when bands[7]..bands[8]
          [HEATS[7], CELL_DARK, 8]
        when bands[8]..bands[9]
          [HEATS[8], CELL_DARK, 9]
        else
          [HEATS[:max], CELL_DARK, 10]
        end
      end

      def analyse_data # rubocop:disable Metrics/AbcSize
        vals = data[1..-2].map { |r| r[1..-2] }.flatten.map { |c| c.nil? ? nil : BigDecimal(c) }
        min = vals.compact.min || 0
        max = vals.compact.max || 100
        range = (max - min) / 10.0
        @bands = 10.times.map { |n| n * range }
        @width = (edge_col_width * 2) + ((data.first.length - 2) * col_width)
        @height = (data.length * row_height) + 50
        calculate_image_dims
      end

      def calculate_image_dims
        cap_width = title.length * 14
        @img_width = [cap_width, width].max
        @startx = img_width > width ? (img_width - width) / 2 : 0
      end

      def start_image
        <<~SVG
          <svg xmlns="http://www.w3.org/2000/svg" class="min-w-full" width="#{img_width}" height="#{height}" viewBox="0 0 #{img_width} #{height}">
            <defs>
              <style>
                .cell-text { font-family: Arial, Helvetica, sans-serif; font-size: 16px; fill: #000; }
                .cell-dark { font-family: Arial, Helvetica, sans-serif; font-size: 16px; fill: #fff; }
                .heading-text { font-family: sans-serif; font-size: 24px; fill: #000; font-weight: regular; }
                .header-text { font-family: sans-serif; font-size: 16px; fill: #fff; font-weight: regular; }
                .header-end { font-family: sans-serif; font-size: 16px; fill: #2563eb; font-weight: regular; }
                .total-text { font-family: sans-serif; font-size: 16px; fill: #000; font-weight: regular; }
                .total-name { font-family: sans-serif; font-size: 16px; fill: #000; font-weight: bold; }
              </style>
            </defs>

          <!-- Background -->
          <rect y="0" width="#{img_width}" height="#{height}" fill="#fff"/>
          <!-- Heading -->
          <text x="#{img_width / 2}" y="30" class="heading-text" text-anchor="middle">#{title}</text>
        SVG
      end

      def end_image
        '</svg>'
      end

      # Format a number as 999k, 999m when over 1000 or 1000000
      #
      # @param number [string,number,nil] the number to format
      def humanize_number(number) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return zero_as || '' if number.nil?
        return number unless human_numbers
        return number if number.to_s.match?(/[a-df-zA-Z-%]/) # Ignore "e" (which will be present for scientific notation)

        number = BigDecimal(number.to_s)
        return zero_as if zero_as && number.zero?

        if number.round(1) >= 1_000_000
          "#{(number / 1_000_000).round(1).to_s('F').sub(/\.0\z/, '')}m"
        elsif number.round(1) >= 1_000
          "#{(number / 1_000).round(1).to_s('F').sub(/\.0\z/, '')}k"
        else
          number.round(1).to_s('F').sub(/\.0\z/, '')
        end
      end
    end
  end
end
