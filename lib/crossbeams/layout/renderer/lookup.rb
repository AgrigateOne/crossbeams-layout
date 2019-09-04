# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a lookup Field (button and optionally hiden inputs).
      class Lookup < Base
        attr_reader :lookup_name, :lookup_key, :hidden_fields, :show_field,
                    :param_keys, :param_values
        def configure(field_name, field_config, page_config)
          @field_name    = field_name
          @field_config  = field_config
          @page_config   = page_config
          @caption       = field_config[:caption] || "Lookup #{present_field_as_label(field_name)}"
          @show_field    = field_config[:show_field]
          @hidden_fields = Array(field_config[:hidden_fields])
          @lookup_name   = field_config.fetch(:lookup_name)
          @lookup_key    = field_config.fetch(:lookup_key)
          @param_keys    = Array(field_config[:param_keys])
          @param_values  = field_config[:param_values] || {}
        end

        def render
          @current_field = @field_name
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <button data-lookup-name="#{lookup_name}" data-lookup-key="#{lookup_key}" #{render_param_keys} #{render_param_values}>#{@caption}</button>#{render_show_field}#{render_hidden_fields}
          </div>#{error_state(newline: false)}
          HTML
        end

        private

        def render_param_keys
          keys = (param_keys + param_values.keys).uniq
          str = keys.empty? ? '[]' : %(["#{keys.join('","')}"])
          %(data-param-keys='#{str}')
        end

        def render_param_values
          str = param_values.map { |k, v| "\"#{k}\":\"#{v}\"" }.join(',')
          %(data-param-values='{#{str}}')
        end

        def render_show_field
          return '' if show_field.nil?

          @current_field = show_field
          <<~HTML

            <input type="text" readonly class="cbl-input label-field bg-light-gray #{@field_config[:css_class]}" value="#{CGI.escapeHTML(value(show_field).to_s)}" #{name_attribute} #{field_id}>
          HTML
        end

        def render_hidden_fields
          return '' if hidden_fields.empty?

          out = []
          hidden_fields.each do |field|
            @current_field = field
            out << <<~HTML
              <input type="hidden" value="#{CGI.escapeHTML(value(field).to_s)}" #{name_attribute} #{field_id} />
            HTML
          end
          out.join("\n")
        end

        # Override Base's value for an input's DOM id.
        def id_base
          "#{@page_config.name}_#{@current_field}"
        end

        # Override Base's value for an input's DOM name.
        def name_base
          %(#{@page_config.name}[#{@current_field}])
        end

        def value(field)
          res = @page_config.form_values.to_h[field] if @page_config.form_values
          res ||= @page_config.form_object.to_h[field]
          res
        end
      end
    end
  end
end
