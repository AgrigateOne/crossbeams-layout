# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardNetworkState
      SC = StylesConfig

      def initialize(opts = {})
        @opts = opts
        @nodes = []
      end

      def render
        <<-HTML
          <div class="flex flex-col border rounded border-blue-300">
            <span class="bg-blue-100 p-3">#{@opts[:label]}</span>
            <div id="ping-#{@opts[:dom_id_base]}" class="#{state_colour(@opts[:ping_state])} m-2 rounded p-3 text-center">#{@opts[:ping_label]}</div>
            <div id="run-#{@opts[:dom_id_base]}" class="#{state_colour(@opts[:run_state])} m-2 rounded p-3 text-center">#{@opts[:run_label]}</div>
          </div>
        HTML
      end

      private

      STATE_COLOURS = {
        undef: 'bg-white text-slate-500',
        ok: SC.css_class(:note_success_contrast),
        notok: SC.css_class(:note_error)
      }.freeze

      def state_colour(state)
        STATE_COLOURS[state]
      end
    end
  end
end
