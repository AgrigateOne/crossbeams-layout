# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardNumber
      attr_reader :options

      SC = StylesConfig

      def initialize(val, options = {})
        @val = val
        @options = options
        @nodes = []
      end

      def render
        size = 'text-3xl'
        bg = 'bg-blue-200' if options[:bg] == :blue
        <<-HTML
          <div class="p-4 rounded-b font-medium #{size} #{bg} flex items-center justify-center">
            #{@val}
          </div>
        HTML
      end
    end
  end
end
