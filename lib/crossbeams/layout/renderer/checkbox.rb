# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Checkbox Field.
      class Checkbox < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render # rubocop:disable Metrics/AbcSize
          attrs = []
          attrs << behaviours
          attrs << 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
          <<-HTML
          <div #{wrapper_id} class="#{div_class}">#{hint_text}
            <input #{name_attribute} type="hidden" value="f">
            <input type="checkbox" value="t" #{checked} #{name_attribute} #{field_id} #{attrs.join(' ')}>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}</label>
            <div class="order-1">#{hint_trigger}</div>
          </div>
          HTML
        end

        private

        def value
          @value ||= @page_config.form_object[@field_name]
        end

        def checked
          value && value != false && value != 'f' && value != 'false' && value.to_s != '0' ? 'checked' : ''
        end
      end
    end
  end
end
