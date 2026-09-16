# frozen_string_literal: true

module Crossbeams
  module Layout
    # Heatmap component for use in LayoutGrid dashboards
    class HeatmapTable # rubocop:disable Metrics/ClassLength
      attr_reader :caption, :human_numbers, :data, :row_height, :edge_col_width, :col_width, :last_row, :width, :height, :bands

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
        @caption = options.fetch(:caption, 'Heatmap')
        @human_numbers = options.fetch(:human_numbers, false)
        @data = data
        @row_height = 40
        @edge_col_width = 80
        @col_width = 64
        @zero_as = options[:zero_as]
        @last_row = data.length - 1
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
          <div data-heatmap="Y" class="m-2">
            #{ar.join("\n")}
          </div>
        HTML
      end

      private

      def render_data
        ar = []
        y = 50
        data.each_with_index do |row, rdx|
          ar << case rdx
                when 0
                  build_header_row(row)
                when last_row
                  build_footer_row(row, y)
                else
                  build_data_row(row, y)
                end
          y += row_height
        end
        ar
      end

      def build_header_row(row) # rubocop:disable Metrics/AbcSize
        len = row.length
        ar = []
        ar << %(<rect x="0" y="50" rx="5" ry="5" width="#{width - edge_col_width}" height="#{row_height}" fill="#2563eb" stroke="#fff" stroke-width="1"/>)
        row.each_with_index do |col, idx|
          x = idx.zero? ? 0 : edge_col_width + ((idx - 1) * col_width)
          w = idx.zero? || idx == len - 1 ? edge_col_width : col_width
          css_class = idx == len - 1 ? 'header-end' : 'header-text'
          ar << %(<text x="#{x.zero? ? w / 2 : x + (w / 2)}" y="#{50 + row_height / 2 + row_height / 10}" text-anchor="middle" class="#{css_class}">#{col}</text>)
        end
        ar.join("\n")
      end

      def build_footer_row(row, y) # rubocop:disable Metrics/AbcSize, Naming/MethodParameterName
        len = row.length
        ar = []
        ar << %(<rect x="0" y="#{y}" rx="5" ry="5" width="#{width}" height="#{row_height}" fill="#e5e7eb" stroke="#fff" stroke-width="1"/>)
        row.each_with_index do |col, idx|
          x = idx.zero? ? 0 : edge_col_width + ((idx - 1) * col_width)
          w = idx.zero? || idx == len - 1 ? edge_col_width : col_width
          css_class = idx.zero? ? 'total-name' : 'total-text'
          ar << %(<text x="#{x.zero? ? w / 2 : x + (w / 2)}" y="#{y + (row_height / 2 + row_height / 10)}" text-anchor="middle" class="#{css_class}">#{humanize_number(col, zero_as: @zero_as)}</text>)
        end
        ar.join("\n")
      end

      def build_data_row(row, y) # rubocop:disable Metrics/AbcSize, Naming/MethodParameterName
        len = row.length
        ar = []
        #  aria-label="Marketing variety: CIR; Standard cartons: 1114987.75597; Grade: Grade 1"
        row.each_with_index do |col, idx|
          x = idx.zero? ? 0 : edge_col_width + ((idx - 1) * col_width)
          w = idx.zero? || idx == len - 1 ? edge_col_width : col_width
          fill, css_class = evaluate_col_fill(col, idx, idx == len - 1)
          ar << <<~SVG
            <rect x="#{x}" y="#{y}" rx="5" ry="5" width="#{w}" height="#{row_height}" fill="#{fill}" class="cell-bg" stroke="#fff" stroke-width="1"/>
            <text x="#{x.zero? ? w / 2 : x + (w / 2)}" y="#{y + (row_height / 2 + row_height / 10)}" text-anchor="middle" aria-label="PUC: x; STD Cartons: #{col ? col.to_f : '-'}; Size: nn" class="#{css_class}">#{humanize_number(col, zero_as: @zero_as)}</text>
          SVG
        end
        ar.join("\n")
      end

      def evaluate_col_fill(col, idx, last_col) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        return ['#e5e7eb', CELL_CLASS] if idx.zero? || last_col
        return [HEATS[:other], CELL_CLASS] if col.nil?

        case BigDecimal(col)
        when bands[0]..bands[1]
          [HEATS[0], CELL_CLASS]
        when bands[1]..bands[2]
          [HEATS[1], CELL_CLASS]
        when bands[2]..bands[3]
          [HEATS[2], CELL_CLASS]
        when bands[3]..bands[4]
          [HEATS[3], CELL_CLASS]
        when bands[4]..bands[5]
          [HEATS[4], CELL_CLASS]
        when bands[5]..bands[6]
          [HEATS[5], CELL_DARK]
        when bands[6]..bands[7]
          [HEATS[6], CELL_DARK]
        when bands[7]..bands[8]
          [HEATS[7], CELL_DARK]
        when bands[8]..bands[9]
          [HEATS[8], CELL_DARK]
        else
          [HEATS[:max], CELL_DARK]
        end
      end

      def analyse_data # rubocop:disable Metrics/AbcSize
        vals = data[1..-2].map { |r| r[1..-2] }.flatten.map { |c| c.nil? ? nil : BigDecimal(c) }
        min = vals.compact.min
        max = vals.compact.max
        range = (max - min) / 10.0
        @bands = 10.times.map { |n| n * range }
        @width = (edge_col_width * 2) + ((data.first.length - 2) * col_width)
        @height = data.length * row_height
      end

      def start_image
        # Using 100% for width & height is OK for a full table, but not for a sparse table.
        # Using the same w & h for viewport maybe renders better, but text should increase?
        <<~SVG
          <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="#{height + 50}" viewBox="0 0 #{width} #{height + 50}">
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

          <!-- Heading -->
          <text x="#{width / 2}" y="30" class="heading-text" text-anchor="middle">#{caption}</text>
          <!-- Background -->
          <rect y="50" width="#{width}" height="#{height}" fill="#fff"/>
        SVG
      end

      def end_image
        '</svg>'
      end

      # Format a number as 999k, 999m when over 1000 or 1000000
      #
      # @param number [string,number,nil] the number to format
      # @param zer_as [string] Optional. A string to return instead of "0".
      def humanize_number(number, zero_as: nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
