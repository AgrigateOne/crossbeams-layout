# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a select Field.
      class Select < BaseSelect
        def configure(field_name, field_config, page_config)
          @field_name = field_name
          @field_config = field_config
          @page_config = page_config
          @caption = field_config[:caption] || present_field_as_label(field_name)
          @searchable = field_config.fetch(:searchable, true)
          @native = field_config.fetch(:native, false)
          @remove_search_for_small_list = field_config.fetch(:remove_search_for_small_list, true)
          @optgroup = optgroup?(@field_config[:options], @field_config[:disabled_options])
          @options_2d = using_2d_options?(@field_config[:options], @field_config[:disabled_options])
          prepare_selected
          prepare_options
          prepare_disabled
        end

        def render
          attrs = apply_attrs # For class, prompt etc...

          render_string(attrs)
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

        def render_string(attrs)
          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{css_style}#{wrapper_visibility}>#{hint_text}
            #{backup_empty_select}
            <select #{attrs.join(' ')} #{name_attribute} #{field_id}>
            #{make_prompt}#{build_1_or_2_options}
            </select>
            <label for="#{id_base}">#{@caption}#{error_state}#{hint_trigger}</label>
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
          sort_items = @field_config.fetch(:sort_items, true) ? 'Y' : 'N'
          %( data-sort-items="#{sort_items}")
        end

        def css_style
          return '' unless @field_config[:min_charwidth]

          %( style="min-width:#{@field_config[:min_charwidth]}rem;")
        end
      end
    end
  end
end
