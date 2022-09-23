# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Radio Group Field.
      class RadioGroup < Base
        def configure(field_name, field_config, page_config)
          @field_name = field_name
          @field_config = field_config
          @page_config = page_config
          set_defaults
        end

        def render
          caption = @field_config[:caption] || present_field_as_label(@field_name)
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <div class="cbl-radio cbl-input">
              #{render_buttons}
            </div>
            <label #{tooltip}>#{caption}#{error_state}</label>
            <div class="order-1">#{hint_trigger}</div>
          </div>
          HTML
        end

        private

        def set_defaults # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          @options = @field_config[:options]
          raise ArgumentError, %(Options must be specified for RadioGroup "#{@field_name}") if @options.nil? || @options.empty?
          raise ArgumentError, %(Options must be 2D array for RadioGroup "#{@field_name}") unless @options.all? { |o| o.length == 2 }
          raise ArgumentError, %(Options must be unique for RadioGroup "#{@field_name}") if @options.map(&:last).uniq.length != @options.length

          @disabled_options = @field_config[:disabled_options] || []
          raise ArgumentError, 'Disabled options must be an array of strings' unless @disabled_options.all? { |o| o.is_a?(String) }

          @initial_value = @field_config[:initial_value] || @options.first.last
        end

        def render_buttons
          attrs = []
          attrs << behaviours
          @options.map do |text, val|
            <<~HTML
              <input type="radio" #{field_id(val.gsub(' ', '_'))} #{name_attribute} value="#{val}"#{checked(val)}#{disabled(val)} #{attrs.join(' ')}>
              <label for="#{id_base}_#{val.gsub(' ', '_')}">#{text}</label>
            HTML
          end.join(' ')
        end

        def value
          @value ||= form_object_value
        end

        def checked_value
          @checked_value ||= @options.any? { |o| o.last == value } ? value : @initial_value
        end

        def checked(opt)
          opt == checked_value ? ' checked' : ''
        end

        def disabled(opt)
          @disabled_options.include?(opt) ? ' disabled' : ''
        end

        def tooltip
          return '' unless @field_config[:tooltip]

          %( title="#{@field_config[:tooltip]}")
        end
      end
    end
  end
end
