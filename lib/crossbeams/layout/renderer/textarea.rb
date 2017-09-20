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

        def render
          cols = @field_config[:cols] || 20
          rows = @field_config[:rows] || 10

          attrs = []
          attrs << 'class="cbl-input"'
          attrs << "placeholder=\"#{@field_config[:placeholder]}\"" if @field_config[:placeholder]
          attrs << "title=\"#{@field_config[:title]}\"" if @field_config[:title]
          attrs << "maxlength=\"#{@field_config[:maxlength]}\"" if @field_config[:maxlength]
          attrs << "minlength=\"#{@field_config[:minlength]}\"" if @field_config[:minlength]
          attrs << 'readonly="true"' if @field_config[:readonly] && @field_config[:readonly] == true
          attrs << 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
          attrs << 'required="true"' if @field_config[:required] && @field_config[:required] == true

          <<~EOS
          <div class="#{div_class}">
            <textarea name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.compact.join(' ')} cols="#{cols}" rows="#{rows}">
            #{CGI::escapeHTML(value.to_s)}
            </textarea>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}</label>
          </div>
          EOS
        end

        private

        def value
          res = @page_config.form_object.send(@field_name)
          res = @page_config.form_values[@field_name] if @page_config.form_values
          res
        end
      end
    end
  end
end

