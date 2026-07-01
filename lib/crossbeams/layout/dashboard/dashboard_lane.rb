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

      def sub_caption(caption)
        @sub_caption = caption
      end

      def no_data(msg = nil)
        @nodes << NoData.new(msg: msg)
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
        <<-HTML
          <div class="mt-3 mb-5 flex flex-col bg-slate-100 border rounded-md border-slate-300 px-3 py-3 gap-3">
            #{show_caption}
            #{show_sub_caption}
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

      def show_sub_caption
        return nil if @sub_caption.nil?

        str = if @sub_caption.is_a?(Array)
                %(<span>#{@sub_caption.join('</span><span class="ml-2 text-blue-500 font-normal">|</span><span class="ml-1">')}</span>)
              else
                @sub_caption
              end
        %(<h3 class="ml-3 #{SC.css_class(:h3)}">#{str}</h3>)
      end
    end
  end
end
