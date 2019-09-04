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
            value = form_object_value
            value = value.to_s('F') if value.is_a?(BigDecimal)
          end
          <<-HTML
          <div #{wrapper_id} class="crossbeams-field"#{wrapper_visibility}>#{hint_text}
            #{render_field(value)}
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{hint_trigger}</label>
          </div>
          HTML
        end

        private

        def render_field(value)
          if @field_config[:as_boolean]
            if value
              <<~HTML
                <div class="cbl-input dark-green">
                  #{Icon.render(:checkon, css_class: 'mr1')}
                </div>
              HTML
            else
              <<~HTML
                <div class="cbl-input light-red">
                  #{Icon.render(:checkoff, css_class: 'mr1')}
                </div>
              HTML
            end
          else
            val = value.to_s.strip.empty? ? '&nbsp;' : CGI.escapeHTML(value.to_s)
            <<-HTML
              <div class="cbl-input label-field bg-light-gray #{@field_config[:css_class]}" #{field_id}>#{val}</div>
            HTML
          end
        end
      end
    end
  end
end
