# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a select Field.
      class Select < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
          @searchable   = field_config.fetch(:searchable) { true }
        end

        def render
          attrs = [] # For class, prompt etc...
          cls   = []
          cls   << 'searchable-select' if @searchable
          cls   << 'cbl-input' unless @searchable
          attrs << "class=\"#{cls.join(' ')}\"" unless cls.empty?
          attrs << 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
          attrs << behaviours
          sel = @field_config[:selected] || @page_config.form_object[@field_name]
          sel = @page_config.form_values[@field_name] if @page_config.form_values

          disabled_option = find_disabled_option(sel, @field_config[:disabled_options])

          render_string(attrs, sel, disabled_option)
        end

        private

        def render_string(attrs, sel, disabled_option)
          <<-HTML
          <div class="#{div_class}">#{hint_text}
            <select #{attrs.join(' ')} name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}">
            #{make_prompt}#{make_options(Array(@field_config[:options]), sel, disabled_option)}
            </select>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
          </div>
          HTML
        end

        def make_prompt
          return '' unless @field_config[:prompt]
          str = @field_config[:prompt].is_a?(String) ? @field_config[:prompt] : 'Select a value'
          "<option value=\"\">#{str}</option>\n"
        end

        def make_options(list, selected = nil, disabled_option = nil)
          disabled = disabled_string(disabled_option, selected)
          opts = list.map do |a|
            a.is_a?(Array) ? option_string(a.first, a.last, selected) : option_string(a, a, selected)
          end
          opts.unshift(disabled) unless disabled.nil?
          opts.join("\n")
        end

        def option_string(text, value, selected, disabled = '')
          sel = selected && value.to_s == selected.to_s ? ' selected ' : ''
          "<option value=\"#{CGI.escapeHTML(value.to_s)}\"#{sel}#{disabled}>#{CGI.escapeHTML(text.to_s)}</option>"
        end

        def find_disabled_option(sel, disabled_list)
          return nil if disabled_list.nil? || disabled_list.empty?
          return nil if sel.nil?
          elem = if disabled_list.first.is_a? Array
                   disabled_list.rassoc(sel)
                 elsif disabled_list.include?(sel)
                   sel
                 end
          elem
        end

        def disabled_string(disabled_option, selected)
          return nil if disabled_option.nil?

          if disabled_option.is_a?(Array)
            option_string(disabled_option.first, disabled_option.last, selected, ' disabled')
          else
            option_string(disabled_option, disabled_option, selected, ' disabled')
          end
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
