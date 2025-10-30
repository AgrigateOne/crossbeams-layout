# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard Item Set - holds a set of items
    class DashboardItemSet
      attr_reader :nodes

      SC = StylesConfig

      def initialize
        @nodes = []
      end

      def item
        node = DashboardItem.new
        yield node
        @nodes << node
      end

      def render
        <<-HTML
          <div class="grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))] flex-wrap gap-6">
            #{nodes.map(&:render).join("\n")}
          </div>
        HTML
      end
    end
  end
end
