# frozen_string_literal: true

module Crossbeams
  module Layout
    # A progress steps renderer - for displaying position in a multi-step process.
    class ProgressStep
      extend MethodBuilder

      build_methods_for :csrf
      attr_reader :steps, :page_config, :position, :state_description,
                  :show_finished, :current_step_id, :size, :bottom_margin

      SIZES = %i[small medium default].freeze

      def initialize(page_config, steps, opts = {})
        @steps             = steps
        @page_config       = page_config
        @nodes             = []
        init_position(opts[:position])
        init_finished(opts[:show_finished])
        check_size(opts)
        @state_description = Array(opts[:state_description])
        @current_step_id   = opts[:current_step_id] || 'cbl-current-step'
      end

      # Is this control invisible?
      def invisible?
        false
      end

      # Is this control hidden?
      def hidden?
        false
      end

      def render
        <<~HTML
          <div class="w-2/3 my-7 mx-auto overflow-x-auto scrollbar-hidden#{xtra_class}"#{max_size}>
            <div class="flex pb-5 px-10 m-auto" style="min-width: 19.5rem; width: #{status_bar_width}%;">
              #{render_steps}
            </div>
          </div>
        HTML
      end

      private

      def xtra_class
        return '' unless bottom_margin

        " mb-#{bottom_margin}"
      end

      def max_size
        case size
        when :small
          ' style=max-width:30rem"'
        when :medium
          ' style=max-width:60rem"'
        else
          ''
        end
      end

      def status_bar_width
        100.0 - step_width
      end

      def render_steps
        fullness = ''
        steps.map.with_index do |step, index|
          colour = position >= index ? 'ocean-700' : 'slate-500'
          line = <<~HTML
            <div class="h-px w-full grow bg-slate-200 ">
            </div>
          HTML
          # For now, drop the description.. (probably impossible to render properly below the step with this design)
          # description = state_description[index]
          # desc = description.nil? ? '' : %(<div class="mt-6 text-slate-600">#{description}</div>)
          str = <<~HTML
            <div class="flex items-center#{fullness}">
              #{index.positive? ? line : ''}
              <div class="grid place-items-center rounded-full w-6 h-6 relative grow-0 shrink-0 bg-#{colour}">
                <span class="text-xs select-none text-white">
                  #{index + 1}
                </span>
                <span class="text-sm font-semibold select-none text-center whitespace-nowrap w-fit absolute left-1/2 -translate-x-1/2 -bottom-5 text-#{colour}">
                  #{step}
                </span>
              </div>
            </div>
          HTML
          fullness = ' w-full'
          str
        end.join("\n")
      end

      def step_width
        (100.0 / steps.length).floor(2)
      end

      def init_position(value)
        @position = [(value || 0).abs, steps.length - 1].min
      end

      def init_finished(value)
        @show_finished = value && position == steps.length - 1
      end

      def check_size(opts)
        @size = opts[:size] || :default
        raise ArgumentError, "Crossbeams::Layout::ProgressStep: Size must be one of #{SIZES.join(', ')}" unless SIZES.include?(@size)

        @bottom_margin = opts[:bottom_margin].to_i
        @bottom_margin = nil if bottom_margin.zero?
        return if bottom_margin.nil?
        raise ArgumentError, 'Crossbeams::Layout::ProgressStep: Bottom margin must be between 1 and 7' unless (1..7).include?(bottom_margin)
      end
    end
  end
end
