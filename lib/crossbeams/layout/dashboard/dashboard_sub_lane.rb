# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardSubLane
      attr_reader :nodes

      SC = StylesConfig

      def initialize(options = {})
        @caption = options[:caption]
        @nodes = []
      end

      def caption(caption)
        @caption = caption
      end

      def item_set
        node = DashboardItemSet.new
        yield node
        @nodes << node
      end

      def render
        <<-HTML
          #{show_caption}
          #{nodes.map(&:render).join("\n")}
        HTML
      end

      private

      # Need to include sub head and right heads too
      def show_caption
        return nil if @caption.nil?

        %(<h3 class="#{SC.css_class(:h3)}">#{@caption}</h3>)
      end
    end
  end
end
