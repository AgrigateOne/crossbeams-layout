# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a multiselect Field that will be presented as two lists.
      class Multi < BaseSelect
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
          @optgroup = optgroup?(@field_config[:options], [])
          @options_2d = using_2d_options?(@field_config[:options], [])
          prepare_selected
          prepare_options
          @disabled_options = @optgroup ? {} : []
        end

        def render
          attrs = [] # For class, prompt etc...
          cls   = []
          cls   << 'searchable-multi'
          attrs << "class=\"#{cls.join(' ')}\"" unless cls.empty?
          attrs << behaviours

          render_string(attrs)
        end

        private

        def render_string(attrs)
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}
            <label for="#{id_base}">#{@caption}#{error_state}#{hint_trigger}</label>
            <select #{attrs.join(' ')} #{name_attribute_multi} #{field_id} multiple="multiple" data-multi="true"#{required_str}#{disabled_str}>
            #{make_prompt}#{build_1_or_2_options}
            </select>
          </div>
          HTML
        end

        def required_str
          @field_config[:required] ? ' required' : ''
        end

        def disabled_str
          @field_config[:disabled] ? ' disabled' : ''
        end

        def make_prompt
          return '' unless @field_config[:prompt]

          str = @field_config[:prompt].is_a?(String) ? @field_config[:prompt] : 'Select a value'
          "<option value=\"\">#{str}</option>\n"
        end
      end
    end
  end
end
