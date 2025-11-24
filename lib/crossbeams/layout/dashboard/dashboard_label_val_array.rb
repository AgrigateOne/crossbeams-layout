# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard Label/value array
    class DashboardLabelValArray
      attr_reader :ary, :options

      SC = StylesConfig

      def initialize(ary, options)
        @ary = ary
        @options = options
        @nodes = []
      end

      def render
        <<-HTML
          <div class="#{big_text_class} mt-3 grid grid-cols-#{ary.length} grid-rows-2 gap-x-2#{bg}">
            <div>#{ary.map(&:first).join('</div><div>')}</div>
            <div class="text-blue-600">#{ary.map(&:last).join('</div><div class="text-blue-600">')}</div>
          </div>
        HTML
      end

      private

      def big_text_class
        return '' unless options[:big_text]

        'text-3xl '
      end

      def bg
        return '' unless options[:bg]

        ' bg-slate-200' # if :gray
      end
    end
  end
end
