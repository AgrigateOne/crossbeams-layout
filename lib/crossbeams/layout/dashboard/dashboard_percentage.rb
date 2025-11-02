# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard percentage
    class DashboardPercentage
      attr_reader :options

      SC = StylesConfig

      def initialize(val, options = {})
        @val = val
        @options = options
      end

      def render
        size = options[:large] ? 'text-5xl' : 'text-3xl'
        <<-HTML
          <div class="p-4 font-medium #{size} #{text_colour} flex items-center justify-center">
          <span class="text-center">
            #{format_text}
            #{sub_text}
            </span>
          </div>
        HTML
      end

      private

      def format_text
        return options[:zero_text] || '0%' if @val.zero?

        "#{@val}%"
      end

      def sub_text
        return '' unless options[:sub_text]

        %(<br><span class="text-base font-normal align-super">#{options[:sub_text]}</span>)
      end

      def text_colour
        case @val
        when 0...50
          'text-orange-600'
        when 50...60
          'text-red-600'
        when 60...80
          'text-blue-600'
        else
          'text-green-600'
        end
      end
    end
  end
end
