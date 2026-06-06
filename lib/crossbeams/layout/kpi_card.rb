# frozen_string_literal: true

module Crossbeams
  module Layout
    # Show a KPI measurement in a card
    class KPICard
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :text, :page_config, :measure

      def initialize(page_config, text, measure)
        @text = text
        @page_config = page_config
        @nodes = []
        @measure = measure
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        <<~HTML
          <div data-kpi="y" class="p-6 rounded-2xl border border-slate-300 m-2 bg-white">
            <div data-kpi-title="y" class="w-full text-2xl p-3 text-center">#{text}</div>
            <div data-kpi-measure="y" class="text-blue-600 text-5xl p-3 text-center">#{measure}</div>
          </div>
        HTML
      end
    end
  end
end
