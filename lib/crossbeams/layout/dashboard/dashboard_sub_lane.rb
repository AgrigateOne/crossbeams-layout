# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard sub-lane
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

      def no_data(msg = nil)
        @nodes << NoData.new(msg: msg)
      end

      def item_set
        node = DashboardItemSet.new
        yield node
        @nodes << node
      end

      def render
        <<-HTML
          <div class="mt-3 mb-5 flex flex-col bg-slate-100 px-3 py-3 gap-3">
            #{show_caption}
            #{nodes.map(&:render).join("\n")}
          </div>
        HTML
      end

      private

      def show_caption
        return nil if @caption.nil?

        %(<h3 class="#{SC.css_class(:h3)}">#{@caption}</h3>)
      end
    end
  end
end
