# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a label Field.
      class Label < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          value = @page_config.form_object.send(@field_name)
          value = value.to_s('F') if value.is_a?(BigDecimal)
          <<-EOS
          <div class="crossbeams-field">
            <input type="text" readonly class="cbl-input label-field bg-light-gray" value="#{CGI::escapeHTML(value.to_s)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
          </div>
          EOS
        end
      end
    end
  end
end
