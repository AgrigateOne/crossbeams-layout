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
            <label for="#{id_base}">#{@caption}#{hint_trigger}</label> #{render_hidden(value)}
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
            val = value.to_s.strip.empty? ? '&nbsp;' : CGI.escapeHTML(apply_formatting(value).to_s)
            <<-HTML
              <div class="cbl-input label-field bg-light-gray #{@field_config[:css_class]}" #{field_id}>#{preformat_start}#{val}#{preformat_end}</div>
            HTML
          end
        end

        def render_hidden(value)
          return '' unless @field_config[:include_hidden_field]

          hidden_value = @field_config[:hidden_value] || value
          %(<input type="hidden" value="#{CGI.escapeHTML(hidden_value.to_s)}" #{name_attribute} />)
        end

        def apply_formatting(val)
          return val unless @field_config[:format]

          case @field_config[:format]
          when :without_timezone
            val.to_s.sub(/ \+\d\d\d\d$/, '')
          when :without_timezone_or_seconds
            val.to_s.sub(/:\d\d \+\d\d\d\d$/, '')
          else
            val
          end
        end

        def preformat_start
          return '' unless @field_config[:format] == :preformat

          '<pre>'
        end

        def preformat_end
          return '' unless @field_config[:format] == :preformat

          '</pre>'
        end
      end
    end
  end
end
