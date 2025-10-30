# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardLane
      attr_reader :nodes

      SC = StylesConfig

      def initialize(options = {})
        @caption = options[:caption]
        @nodes = []
      end

      # TODO: allow for sub-caption and 2 right-captions
      def caption(caption)
        @caption = caption
      end

      def no_data(msg = nil)
        @no_data = msg || 'There is no data to display'
      end

      def sublane(options = {})
        node = DashboardSubLane.new(options)
        yield node
        @nodes << node
      end

      def item_set
        node = DashboardItemSet.new
        yield node
        @nodes << node
      end

      def render
        sublanes = @nodes.any? { |node| node.is_a?(DashboardSubLane) }
        cls = sublanes ? 'flex-row' : 'flex-col'
        <<-HTML
          <div class="mt-3 mb-5 flex #{cls} bg-slate-100 border rounded-md border-slate-300 px-3 py-3 gap-3">
            #{show_caption}
            #{show_no_data}
            #{nodes.map(&:render).join("\n")}
          </div>
        HTML
      end

      private

      # Need to include sub head and right heads too
      def show_caption
        return nil if @caption.nil?

        %(<h2 class="#{SC.css_class(:h2)}">#{@caption}</h2>)
      end

      def show_no_data
        return nil if @no_data.nil?

        %(<div class="p-2 bg-blue-200 text-blue-900">#{@no_data}</div>)
      end
    end
  end
end
