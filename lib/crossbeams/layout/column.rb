# frozen_string_literal: true

module Crossbeams
  module Layout
    # A column is part of a Row.
    class Column
      include PageNode
      attr_reader :css_class, :nodes, :page_config, :colwidth

      def initialize(page_config, size, _seq1, _seq2)
        @nodes = []
        raise ArgumentError, %(Unknown column size "#{size}".) unless %i[full half third quarter].include?(size)

        @colwidth = size || :full
        @page_config = page_config
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def self.make_column(page_config)
        new(page_config, :full, nil, nil)
      end

      # Include a fold-up in the column.
      def fold_up
        fold_up = FoldUp.new(page_config, nodes.length + 1)
        yield fold_up
        @nodes << fold_up
      end

      def expand_collapse(options = {})
        exp_col = ExpandCollapseFolds.new(page_config, nodes.length + 1, options)
        @nodes << exp_col
      end

      def add_field(name, options = {})
        @nodes << Field.new(page_config, name, options)
      end

      def add_list(items, options = {})
        @nodes << List.new(page_config, items, options)
      end

      def add_sortable_list(prefix, items, options = {})
        @nodes << SortableList.new(page_config, prefix, items, options)
      end

      def add_text(text, opts = {})
        @nodes << Text.new(page_config, text, opts)
      end

      def add_notice(text, opts = {})
        @nodes << Notice.new(page_config, text, opts)
      end

      # Add a table to the column.
      def add_table(rows, columns, options = {})
        @nodes << Table.new(page_config, rows, columns, options)
      end

      def add_grid(grid_id, url, options = {})
        @nodes << Grid.new(page_config, grid_id, url, options)
      end

      def add_address(addresses, opts = {})
        @nodes << Address.new(page_config, addresses, opts)
      end

      def add_contact_method(contact_methods, options = {})
        @nodes << ContactMethod.new(page_config, contact_methods, options)
      end

      def add_diff(key)
        @nodes << Diff.new(page_config, key)
      end

      # Add a repeating request to the column.
      def add_repeating_request(url, interval, content)
        @nodes << RepeatingRequest.new(page_config, url, interval, content)
      end

      # Add a control (button, link) to the column.
      #
      # @return [void]
      def add_control(page_control_definition)
        raise ArgumentError, 'Column: "add_control" did not provide a "control_type"' unless page_control_definition[:control_type]

        @nodes << Link.new(page_control_definition) if page_control_definition[:control_type] == :link
        @nodes << DropdownButton.new(page_control_definition) if page_control_definition[:control_type] == :dropdown_button
      end

      def add_node(node)
        @nodes << node
      end

      def render
        if invisible?
          ''
        else
          field_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Col -->\n")
          <<-HTML
          <div class="crossbeams-col#{column_width}">
            #{field_renders}
          </div>
          HTML
        end
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      def dom_loaded?
        has_js = false
        nodes.reject(&:invisible?).each do |node|
          has_js = true if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        has_js
      end

      # DOM loaded javascript snippets.
      def list_dom_loaded
        ar = []
        nodes.reject(&:invisible?).each do |node|
          ar += node.list_dom_loaded if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        ar
      end

      private

      def column_width
        return '' if colwidth == :full
        return ' w-50-ns' if colwidth == :half
        return ' w-33-ns' if colwidth == :third

        ' w-25-ns'
      end
    end
  end
end
