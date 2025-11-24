# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard Label/value array
    class DashboardRichTable
      attr_reader :ary

      SC = StylesConfig

      def initialize(ary)
        @ary = ary
        @nodes = []
      end

      def render
        <<-HTML
          <div class="mt-2">
            #{ary.map { |a| array_render(a) }.join("\n")}
          </div>
        HTML
      end

      private

      def array_render(item)
        <<-HTML
          <div class="grid grid-cols-3 grid-rows-1">
            #{item_render(item[:left])}
            #{item_render(item[:center])}
            #{item_render(item[:right])}
          </div>
        HTML
      end

      def item_render(rec)
        return '<div class="p-1"></div>' if rec.nil?

        return head_col_render(rec) if rec[:type] == :head_col

        align = rec[:align] == :right ? ' text-right' : ''
        <<~HTML
          <div class="p-1 grid grid-cols-2">
            <div class="text-center col-span-2">#{rec[:header]}</div>
            <div class="px-1#{align}">#{rec[:table].map(&:first).join(%(</div><div class="px-1 border-l border-slate-900 #{align}">))}</div>
            <div class="px-1 text-blue-600#{align}">#{rec[:table].map(&:last).join(%(</div><div class="px-1 border-l border-slate-900 text-blue-600#{align}">))}</div>
          </div>
        HTML
      end

      def head_col_render(rec)
        <<~HTML
          <div class="text-center p-1#{bg(rec)}">#{rec[:header]}</div>
        HTML
      end

      def bg(options)
        return '' unless options[:bg]

        ' bg-slate-200' # if :gray
      end
    end
  end
end
