# frozen_string_literal: true

module Crossbeams
  module Layout
    # A column is part of a Row.
    class Column
      include PageNode
      attr_reader :css_class, :nodes, :page_config

      # def initialize(page_config, size, seq1, seq2)
      def initialize(page_config, size, _, _)
        @nodes = []
        case size
        when :full
          @css_class = 'pure-u-1'
        when :half
          @css_class = 'pure-u-1 pure-u-md-1-2'
        when :third
          @css_class = 'pure-u-1 pure-u-md-1-3'
        when :quarter
          @css_class = 'pure-u-1 pure-u-md-1-4'
        else
          raise ArgumentError, "Unknown column size \"#{size}\"."
        end
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

      # TODO: add_link; add_link_collection

      def add_node(node)
        @nodes << node
      end

      def render
        if invisible?
          ''
        else
          field_renders = nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Col -->\n")
          <<-HTML
          <div class="crossbeams-col">
            #{field_renders}
          </div>
          HTML
        end
      end
    end
  end
end
