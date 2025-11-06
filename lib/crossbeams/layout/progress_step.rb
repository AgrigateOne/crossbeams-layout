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

      # Render the control
      def render_old
        # <<-HTML
        #   <div class="cbl-progress-bar-wrapper"#{max_size}>
        #     <div class="cbl-progress-status-bar" style="width: #{status_bar_width}%;">
        #       <div class="cbl-current-status" style="width: #{current_position}%; transition: width 4500ms linear;">
        #       </div>
        #     </div>
        #     <ul class="cbl-progress-bar">
        #       #{render_steps}
        #     </ul>
        #   </div>
        #   #{render_state}
        # HTML
        <<-HTML
          <div class="w-full"#{max_size}>
            <div class="h-0.5 relative top-5 my-0 mx-auto bg-slate-400" style="width: #{status_bar_width}%;">
              <div class="bg-ocean-500" style="width: #{current_position}%; transition: width 4500ms linear;">
              </div>
            </div>
            <ul class="w-full m-0 p-0" style="font-size: 0">
              #{render_steps}
            </ul>
          </div>
          #{render_state}
        HTML
      end

      def render
        <<~HTML
          <div class="w-2/3 my-3 mx-auto overflow-x-auto scrollbar-hidden#{xtra_class}"#{max_size}>
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

      def current_position
        return 0 if position.zero?

        100.0 / (steps.length - 1) * position
      end

      def render_steps
        # width = step_width
        fullness = ''
        steps.map.with_index do |step, index|
          # css_class = ['cbl-step']
          # css_class += position_classes(index, position)
          # id = position_id(index, position)
          # %(<li class="#{css_class.join(' ')}"#{id} style="width: #{width}%;">#{step}</li>)
          colour = position >= index ? 'ocean' : 'slate'
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
              <div class="grid place-items-center rounded-full w-6 h-6 relative grow-0 shrink-0 bg-#{colour}-500">
                <span class="text-xs select-none text-white">
                  #{index + 1}
                </span>
                <span class="text-sm font-semibold select-none text-center whitespace-nowrap w-fit absolute left-1/2 -translate-x-1/2 -bottom-5 text-#{colour}-500">
                  #{step}
                </span>
              </div>
            </div>
          HTML
          fullness = ' w-full'
          str
        end.join("\n")
        # <<~HTML
        #   <div class="flex items-center">
        #     <div class="grid place-items-center rounded-full w-6 h-6 relative grow-0 shrink-0 bg-ocean-500">
        #       <span class="text-xs select-none text-white">
        #         1
        #       </span>
        #       <span class="text-sm font-semibold select-none text-center whitespace-nowrap w-fit absolute left-1/2 -translate-x-1/2 -bottom-5 text-ocean-500">
        #         Template details
        #       </span>
        #     </div>
        #   </div>
        #   <div class="flex items-center w-full ">
        #     <div class="h-px w-full grow bg-slate-200 ">
        #     </div>
        #     <div class="grid place-items-center rounded-full w-6 h-6 relative grow-0 shrink-0 bg-slate-200">
        #       <span class="text-xs select-none text-slate-500">
        #         2
        #       </span>
        #       <span class="text-sm font-semibold select-none text-center truncate w-24 absolute left-1/2 -translate-x-1/2 -bottom-5 text-slate-500">
        #         Select fields </span>
        #     </div>
        #   </div>
        #   <div class="mr-7 flex items-center w-full ">
        #     <div class="h-px w-full grow bg-slate-200 ">
        #     </div>
        #     <div class="grid place-items-center rounded-full w-6 h-6 relative grow-0 shrink-0 bg-slate-200">
        #       <span class="text-xs select-none text-slate-500">
        #         3
        #       </span>
        #       <span class="text-sm font-semibold select-none text-center whitespace-nowrap absolute left-1/2 -translate-x-1/2 -bottom-5 text-slate-500">
        #         Populate default values </span>
        #     </div>
        #   </div>
        # HTML
      end

      def render_steps_old
        width = step_width
        steps.map.with_index do |step, index|
          css_class = ['cbl-step']
          css_class += position_classes(index, position)
          id = position_id(index, position)
          %(<li class="#{css_class.join(' ')}"#{id} style="width: #{width}%;">#{step}</li>)
        end.join("\n")
      end

      def position_classes(index, position)
        classes = []
        classes << 'visited' if position > index
        if position == index
          if show_finished
            classes << 'visited'
            classes << 'current'
          else
            classes << 'busy'
          end
        end
        classes
      end

      def position_id(index, position)
        position == index ? %( id="#{current_step_id}") : ''
      end

      def step_width
        (100.0 / steps.length).floor(2)
      end

      def render_state
        return nil if state_description.empty?

        <<-HTML
          <div class="cbl-progress-bar-text">
            <ul class="cbl-progress-state">
              #{state_description.map { |d| "<li>#{d}</li>" }.join("\n")}
            </ul>
          </div>
        HTML
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
