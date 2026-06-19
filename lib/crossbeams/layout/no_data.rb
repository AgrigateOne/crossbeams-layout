# frozen_string_literal: true

module Crossbeams
  module Layout
    # Display a block with a "No data" message
    class NoData
      extend MethodBuilder

      build_methods_for :csrf

      attr_reader :nodes, :msg, :sub_msg

      def initialize(options = {})
        @msg = options[:msg] || 'There is no data to display'
        @sub_msg = options[:sub_msg]
        @nodes = []
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        <<~HTML
          <div class="mx-3 bg-white p-7 flex flex-col items-center gap-6 rounded-lg shadow-lg">
            <div class="text-3xl font-medium text-sky-900">
              #{msg}
            </div>
            <div class="text-slate-500">
              #{sub_msg}
            </div>
            <img class="" src="/images/packhouse.png">
          </div>
        HTML
      end
    end
  end
end
