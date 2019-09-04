# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a select Field.
      class Select < Base # rubocop:disable Metrics/ClassLength
        def configure(field_name, field_config, page_config)
          @field_name = field_name
          @field_config = field_config
          @page_config = page_config
          @caption = field_config[:caption] || present_field_as_label(field_name)
          @searchable = field_config.fetch(:searchable) { true }
          @native = field_config.fetch(:native) { false }
          @remove_search_for_small_list = field_config.fetch(:remove_search_for_small_list) { true }
        end

        def render
          attrs = apply_attrs # For class, prompt etc...
          sel = @field_config[:selected] || form_object_value
          sel = @page_config.form_values[@field_name] if @page_config.form_values

          disabled_option = find_disabled_option(sel, @field_config[:disabled_options])

          render_string(attrs, sel, disabled_option)
        end

        private

        def apply_attrs # rubocop:disable Metrics/AbcSize
          attrs = [] # For class, prompt etc...
          cls   = apply_classes
          attrs << "class=\"#{cls.join(' ')}\"" unless cls.empty?
          attrs << disabled
          attrs << required
          attrs << clearable
          attrs << behaviours
          attrs << non_searchable
          attrs << auto_hide_search
          attrs << sort_items
          attrs.compact
        end

        def clearable
          %(data-clearable="#{@field_config[:prompt] ? 'true' : 'false'}")
        end

        def disabled
          return nil unless @field_config[:disabled] && @field_config[:disabled] == true

          'disabled="true"'
        end

        def required
          return nil unless @field_config[:required] && @field_config[:required] == true

          'required="true"'
        end

        def apply_classes
          cls = []
          cls << 'searchable-select' unless @native
          cls << 'cbl-input' if @native
          cls
        end

        def render_string(attrs, sel, disabled_option)
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{css_style}#{wrapper_visibility}>#{hint_text}
            #{backup_empty_select}
            <select #{attrs.join(' ')} #{name_attribute} #{field_id}>
            #{make_prompt}#{build_options(@field_config[:options], sel, disabled_option)}
            </select>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
          </div>
          HTML
        end

        def backup_empty_select
          # Hidden blank value to be submitted as a param if the Searchable component box is cleared.
          return '' if @native

          %(<input #{name_attribute} type="hidden" value="">)
        end

        def make_prompt
          return '' unless @field_config[:prompt]

          str = @field_config[:prompt].is_a?(String) ? @field_config[:prompt] : 'Select a value'
          "<option value=\"\" placeholder>#{str}</option>\n"
        end

        def non_searchable
          return nil if @searchable

          %( data-no-search="Y")
        end

        def auto_hide_search
          %( data-auto-hide-search="#{@remove_search_for_small_list ? 'Y' : 'N'}")
        end

        def sort_items
          sort_items = @field_config.fetch(:sort_items) { true } ? 'Y' : 'N'
          %( data-sort-items="#{sort_items}")
        end

        def css_style
          return '' unless @field_config[:min_charwidth]

          %( style="min-width:#{@field_config[:min_charwidth]}rem;")
        end

        def build_options(list, selected = nil, disabled_option = nil)
          if list.is_a?(Hash)
            grp_disabled = disabled_option
            opts = []
            list.each do |group, sublist|
              opts << %(<optgroup label="#{group}">)
              opts << make_options(Array(sublist), selected, grp_disabled)
              opts << '</optgroup>'
              grp_disabled = nil # This might not be quite the right position...
            end
            opts.join("\n")
          else
            make_options(Array(list), selected, disabled_option)
          end
        end

        def make_options(list, selected, disabled_option)
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
      end
    end
  end
end
