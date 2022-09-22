# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Checkbox Field.
      class RadioGroup < Base
        def configure(field_name, field_config, page_config)
          @field_name = field_name
          @field_config = field_config
          @page_config = page_config
          @caption = field_config[:caption] || present_field_as_label(field_name)
          @tooltip = field_config[:tooltip]
          @options = field_config[:options]
          raise ArgumentError, "Options must be specified for RadioGroup #{field_name}" if @options.nil? || @options.empty?
          raise ArgumentError, "Options must be unique for RadioGroup #{field_name}" if @options.uniq.length != @options.length

          @initial_value = field_config[:initial_value] || @options.first[:value]
        end

        def render
          attrs = []
          attrs << behaviours
          attrs << 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <div class="cbl-radio cbl-input">
              #{render_buttons}
            </div>
            <label #{tooltip}>#{@caption}#{error_state}</label>
            <div class="order-1">#{hint_trigger}</div>
          </div>
          HTML
        end

        private

        def render_buttons
          @options.map do |opt|
            <<~HTML
              <input type="radio" #{field_id(opt[:value].gsub(' ', '_'))} #{name_attribute} value="#{opt.fetch(:value)}"#{checked(opt[:value])}>
              <label for="#{id_base}_#{opt[:value].gsub(' ', '_')}">#{opt.fetch(:text)}</label>
            HTML
          end.join(' ')
        end

        def value
          @value ||= form_object_value
        end

        def checked_value
          @checked_value ||= @options.any? { |o| o[:value] == value } ? value : @initial_value
        end

        def checked(opt)
          opt == checked_value ? ' checked' : ''
        end

        def tooltip
          return '' unless @tooltip

          %( title="#{@tooltip}")
        end
      end
    end
  end
end
