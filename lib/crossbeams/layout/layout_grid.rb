# frozen_string_literal: true

module Crossbeams
  module Layout
    # A control to render a css grid
    class LayoutGrid
      extend MethodBuilder
      attr_accessor :page_config, :rows

      SC = StylesConfig
      EmptyNode = Struct.new do
        def render
          'Missing element'
        end
      end

      build_methods_for :csrf,
                        :grid,
                        :text,
                        :kpi_card,
                        :chart,
                        :notice

      def initialize(page_config)
        @page_config = page_config
        @nodes = []
        @rows = []
      end

      def specify_row(no_cols)
        raise ArgumentError, 'This is a 12-column grid. A row can only have 1, 2, 3, 4, 6 or 12 columns' unless [1, 2, 3, 4, 6, 12].include? no_cols.to_i

        @rows << no_cols.to_i
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

      def dom_id(val)
        @dom_id = val
      end

      # def add_chart(opts)
      #   @nodes << Chart.new(opts)
      # end

      # Render this node as HTML div containg a collection of buttons or divs
      #
      # @return [string] - HTML representation of this node.
      def render
        # <div style="display: grid;grid-template-columns: repeat(12, 1fr);grid-template-rows:repeat(#{rowcnt}, 1fr);grid-column-gap: 10px">
        <<-HTML
          <div #{dom_id_render}style="display: grid;grid-template-columns: repeat(12, 1fr);grid-template-rows:repeat(1, 1fr);grid-column-gap: 10px">
            #{render_items}
          </div>
        HTML
      end

      # Render just the inner HTML of this control.
      # (For use when replacing a DOM element's inner content)
      #
      # @return [string] - HTML representation of the inner nodes.
      def render_inner
        render_items
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      def dom_loaded?
        has_js = false
        @nodes.reject(&:invisible?).each do |node|
          has_js = true if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        has_js
      end

      # DOM loaded javascript snippets.
      def list_dom_loaded
        ar = []
        @nodes.reject(&:invisible?).each do |node|
          ar += node.list_dom_loaded if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        ar
      end

      private

      def dom_id_render
        return '' unless @dom_id

        %(id="#{@dom_id}" )
      end

      def render_items
        ar = []
        pos = 0
        @rows.each_with_index do |cnt, idx|
          cnt.times do |n|
            row_start, col_start, row_end, col_end = calc_grid_col(idx, cnt, n)
            ar << %(<div style="grid-area: #{row_start} / #{col_start} / #{row_end} / #{col_end}">)
            ar << (@nodes[pos] || Notice.new(page_config, 'This layout has an element missing here', notice_type: :error)).render
            pos += 1
            ar << '</div>'
          end
        end
        ar.join("\n")
      end

      def calc_grid_col(idx, cnt, pos)
        grid_row_start = idx + 1
        grid_column_start = 1 + (pos * (12 / cnt))
        grid_row_end = idx + 1
        grid_column_end = "span #{12 / cnt}"

        [grid_row_start, grid_column_start, grid_row_end, grid_column_end]
      end
    end
  end
end
