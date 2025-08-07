# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a label Field.
      class Label < Base
        SC = StylesConfig

        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
          raise ArgumentError, 'Crossbeams::Layout::Label: `:no_html_escape` can only be used when `:with_value` is used.' if @field_config[:no_escape] && !@field_config[:with_value]
        end

        def render
          if @field_config[:with_value]
            value = @field_config[:with_value]
          else
            value = form_object_value
            value = value.to_s('F') if value.is_a?(BigDecimal)
          end
          # <label for="#{id_base}" class="#{SC.css_class(:label)}">#{@caption}#{hint_trigger}</label> #{render_hidden(value)}
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            #{label_render("#{id_base}_date", @caption)} #{render_hidden(value)}
            #{render_field(value)}
          </div>
          HTML
        end

        private

        def render_field(value)
          if @field_config[:as_boolean]
            if value
              <<~HTML
                <div class="cbl-input text-green-500">
                  #{Icon.render(:checkon, css_class: 'mr-1')}
                </div>
              HTML
            else
              <<~HTML
                <div class="cbl-input text-red-500">
                  #{Icon.render(:checkoff, css_class: 'mr-1')}
                </div>
              HTML
            end
          else
            val = if value.to_s.strip.empty?
                    '&nbsp;'
                  elsif @field_config[:no_html_escape]
                    value
                  else
                    CGI.escapeHTML(apply_formatting(value).to_s)
                  end
            # <<-HTML
            #   <div class="cbl-input label-field bg-gray-200 #{@field_config[:css_class]}" #{label_field_id}>#{preformat_start}#{val}#{preformat_end}</div>
            # HTML
            <<-HTML
              <div class="w-full border rounded leading-4 p-3 bg-gray-200 #{@field_config[:css_class]}" #{label_field_id}>#{preformat_start}#{val}#{preformat_end}</div>
            HTML
          end
        end

        def label_field_id
          return field_id unless @field_config[:include_hidden_field]

          field_id.sub('id="', 'id="lbl_')
        end

        def render_hidden(value)
          return '' unless @field_config[:include_hidden_field]

          hidden_value = @field_config[:hidden_value] || value
          %(<input #{field_id} type="hidden" value="#{CGI.escapeHTML(hidden_value.to_s)}" #{name_attribute} />)
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
