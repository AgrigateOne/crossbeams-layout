module Crossbeams
  module Layout
    class Page
      attr_reader :nodes, :page_config, :sequence

      def initialize(options = {})
        @nodes       = []
        @page_config = PageConfig.new(options)
        @sequence    = 1
      end

      def self.build(&block)
        new.build(&block)
      end

      def build
        yield self, page_config
        self
      end

      def form_object(obj)
        @page_config.form_object = obj
      end

      def section
        section = Section.new(page_config, nodes.length + 1)
        yield section
        @nodes << section
      end

      def callback_section
        section = CallbackSection.new(page_config, nodes.length + 1)
        yield section
        @nodes << section
      end

      def row
        row = Row.new(page_config, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      def form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form
        @nodes << form
      end

      def with_form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form, page_config
        @nodes << form
        self
      end

      def add_grid(grid_id, url, options = {})
        @nodes << Grid.new(page_config, grid_id, url, options)
      end

      def render
        # "A string rendered from Crossbeams<br>" << nodes.map {|s| s.render }.join("\n<!-- End Section -->\n")
        nodes.reject { |node| node.invisible? }.map(&:render).join("\n<!-- End Section -->\n")
      end
    end
  end
end
