# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a textarea field.
      class Textarea < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render # rubocop:disable Metrics/AbcSize
          cols = @field_config[:cols] || 20
          rows = @field_config[:rows] || 10

          <<~HTML
            <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
              <textarea #{name_attribute} #{field_id} #{attr_list.join(' ')} cols="#{cols}" rows="#{rows}">#{CGI.escapeHTML(value.to_s)}</textarea>
              <label for="#{id_base}">#{@caption}#{error_state}#{hint_trigger}</label>
            </div>
          HTML
        end

        private

        def value
          res = form_object_value
          override_with_form_value(res)
        end

        def attr_list
          [
            'class="cbl-input"',
            attr_placeholder,
            attr_title,
            attr_maxlength,
            attr_minlength,
            attr_readonly,
            attr_disabled,
            attr_required,
            behaviours
          ].compact
        end

        def attr_placeholder
          return "placeholder=\"#{@field_config[:placeholder]}\"" if @field_config[:placeholder]
        end

        def attr_title
          return "title=\"#{@field_config[:title]}\"" if @field_config[:title]
        end

        def attr_maxlength
          return "maxlength=\"#{@field_config[:maxlength]}\"" if @field_config[:maxlength]
        end

        def attr_minlength
          return "minlength=\"#{@field_config[:minlength]}\"" if @field_config[:minlength]
        end

        def attr_readonly
          return 'readonly="true"' if @field_config[:readonly] && @field_config[:readonly] == true
        end

        def attr_disabled
          return 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
        end

        def attr_required
          return 'required="true"' if @field_config[:required] && @field_config[:required] == true
        end
      end
    end
  end
end
