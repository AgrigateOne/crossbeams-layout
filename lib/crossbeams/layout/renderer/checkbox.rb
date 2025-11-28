# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Checkbox Field.
      class Checkbox < Base
        SC = StylesConfig

        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
          @tooltip      = field_config[:tooltip]
        end

        def render # rubocop:disable Metrics/AbcSize
          attrs = []
          attrs << behaviours
          attrs << 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true

          <<-HTML
          <div #{wrapper_id} class="#{div_class}#{wrapper_visibility}">#{hint_text}
            <div>&nbsp;</div>
            <input #{name_attribute} type="hidden" value="f">
            <input type="checkbox" value="t" class="#{SC.css_class(:checkbox)} align-middle" #{checked} #{name_attribute} #{field_id} #{attrs.join(' ')}>
            #{label_render(id_base, @caption, inline: true, tooltip: tooltip, pointer: true)}
          </div>
          HTML
        end

        private

        def value
          @value ||= form_object_value
        end

        def checked
          value && value != false && value != 'f' && value != 'false' && value.to_s != '0' ? 'checked' : ''
        end

        def tooltip
          return nil unless @tooltip

          %(title="#{@tooltip}")
        end
      end
    end
  end
end
