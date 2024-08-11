# frozen_string_literal: true

module Crossbeams
  module Layout
    # A progress steps renderer - for displaying positioin in amulti-step process.
    class ProgressStep
      extend MethodBuilder

      node_adders :csrf
      attr_reader :steps, :page_config, :position, :state_description,
                  :show_finished, :current_step_id, :size

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
      def render
        <<-HTML
          <div class="cbl-progress-bar-wrapper"#{max_size}>
            <div class="cbl-progress-status-bar" style="width: #{status_bar_width}%;">
              <div class="cbl-current-status" style="width: #{current_position}%; transition: width 4500ms linear;">
              </div>
            </div>
            <ul class="cbl-progress-bar">
              #{render_steps}
            </ul>
          </div>
          #{render_state}
        HTML
      end

      private

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
        raise ArgumentError, "Size must be one of #{SIZES.join(', ')}" unless SIZES.include?(@size)
      end
    end
  end
end
