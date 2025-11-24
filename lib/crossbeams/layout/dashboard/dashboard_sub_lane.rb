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
        @no_data = msg || 'There is no data to display'
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
            #{show_no_data}
            #{nodes.map(&:render).join("\n")}
          </div>
        HTML
      end

      private

      def show_caption
        return nil if @caption.nil?

        %(<h3 class="#{SC.css_class(:h3)}">#{@caption}</h3>)
      end

      def show_no_data
        return nil if @no_data.nil?

        %(<div class="p-7 bg-blue-200 text-blue-900">#{@no_data}</div>)
      end
    end
  end
end
