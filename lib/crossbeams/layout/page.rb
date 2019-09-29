# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Page obejct holds all other layout elemnts.
    class Page
      attr_reader :nodes, :page_config, :sequence

      def initialize(options = {})
        @nodes       = []
        @page_config = PageConfig.new(options)
        @sequence    = 1
      end

      # Build a page. Instantiates a Page and calls build on it.
      # @param [options]
      def self.build(options = {}, &block)
        new(options).build(&block)
      end

      # Build a page.
      # Passes the page instance and page_config to the block.
      def build
        yield self, page_config
        self
      end

      # Iterate through all nodes and add the CSRF tag to them.
      # (Only Form objects should actually do something with this.
      def add_csrf_tag(tag)
        @nodes.each { |node| node.add_csrf_tag(tag) }
      end

      # Register the form object.
      def form_object(obj)
        @page_config.form_object = obj
      end

      # Register the vlaues that have been filled-in on a form.
      def form_values(values)
        @page_config.form_values = values
      end

      # Register the error conditions for a form.
      def form_errors(errors)
        @page_config.form_errors = errors
        return unless errors && errors[:base_with_highlights]

        Array(errors[:base_with_highlights][:highlights]).each do |field|
          @page_config.form_errors[field] ||= []
          @page_config.form_errors[field] << nil
        end
      end

      # Define a section in the page.
      def section
        section = Section.new(page_config, nodes.length + 1)
        yield section
        @nodes << section
      end

      # Define a section that will lazy-load.
      def callback_section
        section = CallbackSection.new(page_config, nodes.length + 1)
        yield section
        @nodes << section
      end

      # Define a row in the page.
      def row
        row = Row.new(page_config, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      # Define a fold-up in the page.
      def fold_up
        fold_up = FoldUp.new(page_config, nodes.length + 1)
        yield fold_up
        @nodes << fold_up
      end

      # Define a form in the page.
      def form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form
        @nodes << form
      end

      # Work with a form in the layout.
      def with_form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form, page_config
        @nodes << form
        self
      end

      # Add a grid to the page.
      def add_grid(grid_id, url, options = {})
        @nodes << Grid.new(page_config, grid_id, url, options)
      end

      # Add a table to the page.
      def add_table(rows, columns, options = {})
        @nodes << Table.new(page_config, rows, columns, options)
      end

      def add_help_link(options)
        @nodes << HelpLink.new(options)
      end

      def add_text(text, opts = {})
        @nodes << Text.new(page_config, text, opts)
      end

      def add_notice(text, opts = {})
        @nodes << Notice.new(page_config, text, opts)
      end

      def add_diff(key)
        @nodes << Diff.new(page_config, key)
      end

      # Add a repeating request to the page.
      def add_repeating_request(url, interval, content)
        @nodes << RepeatingRequest.new(page_config, url, interval, content)
      end

      # Render the page and all its child nodes.
      def render
        # "A string rendered from Crossbeams<br>" << nodes.map {|s| s.render }.join("\n<!-- End Section -->\n")
        nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Section -->\n")
      end
    end
  end
end
