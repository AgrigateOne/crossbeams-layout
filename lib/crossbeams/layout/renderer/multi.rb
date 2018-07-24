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
          sel = @field_config[:selected] || @page_config.form_object[@field_name] || []

          render_string(attrs, sel)
        end

        private

        def render_string(attrs, sel)
          <<-HTML
          <div class="#{div_class}">#{hint_text}
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
            <select #{attrs.join(' ')} name="#{@page_config.name}[#{@field_name}][]" id="#{@page_config.name}_#{@field_name}" multiple="multiple" data-multi="true"#{required_str}>
            #{make_prompt}#{make_options(Array(@field_config[:options]), sel)}
            </select>
          </div>
          HTML
        end

        def required_str
          @field_config[:required] ? ' required' : ''
        end

        def make_prompt
          return '' unless @field_config[:prompt]
          str = @field_config[:prompt].is_a?(String) ? @field_config[:prompt] : 'Select a value'
          "<option value=\"\">#{str}</option>\n"
        end

        def make_options(opts, selected = [])
          opts.map do |a|
            a.is_a?(Array) ? option_string(a.first, a.last, selected) : option_string(a, a, selected)
          end.join("\n")
        end

        def option_string(text, value, selected)
          sel = selected.include?(value) ? ' selected ' : ''
          "<option value=\"#{CGI.escapeHTML(value.to_s)}\"#{sel}>#{CGI.escapeHTML(text.to_s)}</option>"
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
