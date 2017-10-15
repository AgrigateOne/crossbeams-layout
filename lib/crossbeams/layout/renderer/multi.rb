# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a multiselect Field that will be presented as two lists.
      class Multi < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          attrs = [] # For class, prompt etc...
          cls   = []
          cls   << 'searchable-multi'
          attrs << "class=\"#{cls.join(' ')}\"" unless cls.empty?
          attrs << behaviours
          sel = @field_config[:selected] ? @field_config[:selected] : @page_config.form_object.send(@field_name)

          render_string(attrs, sel)
        end

        private

        def render_string(attrs, sel)
          <<-EOS
          <div class="#{div_class}">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}</label>
            <select #{attrs.join(' ')} name="#{@page_config.name}[#{@field_name}][]" id="#{@page_config.name}_#{@field_name}" multiple="multiple" data-multi="true">
            #{make_prompt}#{make_options(@field_config[:options], sel)}
            </select>
          </div>
          EOS
        end

        def make_prompt
          return '' unless @field_config[:prompt]
          str = @field_config[:prompt].is_a?(String) ? @field_config[:prompt] : 'Select a value'
          "<option value=\"\">#{str}</option>\n"
        end

        def make_options(ar, selected = nil)
          ar.map do |a|
            if a.is_a?(Array)
              # sel = a.last == selected ? ' selected ' : ''
              sel = selected.include?(a.last) ? ' selected ' : ''
              "<option value=\"#{CGI::escapeHTML(a.last.to_s)}\"#{sel}>#{CGI::escapeHTML(a.first.to_s)}</option>"
            else
              # sel = a == selected ? ' selected ' : ''
              sel = selected.include?(a) ? ' selected ' : ''
              "<option value=\"#{CGI::escapeHTML(a.to_s)}\"#{sel}>#{CGI::escapeHTML(a.to_s)}</option>"
            end
          end.join("\n")
        end
      end
    end
  end
end

