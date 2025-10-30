# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard container
    class Dashboard
      attr_reader :nodes

      SC = StylesConfig

      def initialize(options = {})
        @caption = options[:caption]
        @nodes = []
      end

      def build
        yield self
        self
      end

      def self.build(options = {}, &block)
        new(options).build(&block)
      end

      def caption(caption)
        @caption = caption
      end

      def add_sub_caption(caption)
        @nodes << %(<div class="py-2 font-semibold">#{caption}</div>)
      end

      def lane(options = {})
        node = DashboardLane.new(options)
        yield node
        @nodes << node
      end

      def add_repeating_request(url, interval, content)
        @nodes << RepeatingRequest.new({}, url, interval, content)
      end

      def render
        <<-HTML
          #{show_caption}
          #{nodes.map { |n| n.is_a?(String) ? n : n.render }.join("\n")}
        HTML
      end

      def add_csrf_tag(_val)
        nil
      end

      def includes_javascript?
        false
      end

      private

      def show_caption
        return nil if @caption.nil?

        %(<h1 class="#{SC.css_class(:h1)}">#{@caption}</h1>)
      end
    end
  end
end
