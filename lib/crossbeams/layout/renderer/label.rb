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
          if @field_config[:with_value]
            value = @field_config[:with_value]
          else
            value = @page_config.form_object[@field_name]
            value = value.to_s('F') if value.is_a?(BigDecimal)
          end
          <<-HTML
          <div class="crossbeams-field">#{hint_text}
            <input type="text" readonly class="cbl-input label-field bg-light-gray" value="#{CGI.escapeHTML(value.to_s)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{hint_trigger}</label>
          </div>
          HTML
        end

        def hint_text
          return '' unless @field_config[:hint]
          <<~HTML
            <div style="display:none" data-cb-hint="#{@page_config.name}_#{@field_name}">
              #{@field_config[:hint]}
            </div>
          HTML
        end

        def hint_trigger
          return '' unless @field_config[:hint]
          %( <i class="fa fa-question-circle" title="Click for hint" data-cb-hint-for="#{@page_config.name}_#{@field_name}"></i>)
        end
      end
    end
  end
end
