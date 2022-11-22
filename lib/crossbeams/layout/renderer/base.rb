# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Base class for all field renderers.
      class Base # rubocop:disable Metrics/ClassLength
        def initialize
          @dom_loaded = []
        end

        # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
        def dom_loaded?
          !@dom_loaded.empty?
        end

        # Add a Javascript snippet to execute after DOM is loaded.
        def add_dom_loaded(str)
          @dom_loaded << str
        end

        # DOM loaded javascript snippets.
        def list_dom_loaded
          @dom_loaded
        end

        # Create reasonable label text from a field name.
        def present_field_as_label(field)
          field.to_s.sub(/_id$/, '').split('_').map(&:capitalize).join(' ')
        end

        # The class for the field wrapper.
        # (the div surrounding label and input is the wrapper)
        def div_class
          return 'crossbeams-field' unless @page_config.form_errors

          has_err = if @field_config[:parent_field]
                      (@page_config.form_errors[@field_config[:parent_field]] || {})[@field_name]
                    else
                      @page_config.form_errors[@field_name]
                    end
          if has_err
            'crossbeams-field crossbeams-div-error bg-washed-red'
          else
            'crossbeams-field'
          end
        end

        # The value of the field extracted from the form object.
        # This method will dig values out of an +extended_columns+ field if required.
        def form_object_value
          if @field_name.to_s.start_with?('extcol_')
            (@page_config.form_object[:extended_columns] || {})[@field_name.to_s.delete_prefix('extcol_')]
          elsif @field_config[:parent_field]
            parent_hash[@field_name.to_s] || parent_hash[@field_name]
          else
            @page_config.form_object[@field_name]
          end
        end

        # If there is a value in form_values for this field, use it to
        # override the already-set value.
        def override_with_form_value(value)
          return value unless @page_config.form_values

          temp = if @field_config[:parent_field]
                   parent_form_values_hash[@field_name.to_s] || parent_form_values_hash[@field_name]
                 else
                   @page_config.form_values[@field_name]
                 end
          temp.nil? ? value : temp
        end

        # The value for an input's DOM id.
        def id_base
          "#{@page_config.name}_#{parent_field_id}#{@field_name}"
        end

        # The element's id attribute.
        def field_id(suffix = nil)
          extra = suffix ? "_#{suffix}" : ''

          %(id="#{id_base}#{extra}")
        end

        # The field wrapper div's id attribute.
        def wrapper_id
          %(id="#{id_base}_field_wrapper")
        end

        # Initially hide the wrapper.
        def wrapper_visibility
          @field_config[:hide_on_load] = !@field_config[:initially_visible] if @field_config&.key?(:initially_visible)
          return '' unless @field_config[:hide_on_load]

          ' hidden'
        end

        # Parent field name (for a field that is part of a Hash)
        def parent_field
          return '' unless @field_config[:parent_field]

          "[#{@field_config[:parent_field]}]"
        end

        # Parent field id (for a field that is part of a Hash)
        def parent_field_id
          return '' unless @field_config[:parent_field]

          "#{@field_config[:parent_field]}_"
        end

        # The value for an input's DOM name.
        def name_base
          %(#{@page_config.name}#{parent_field}[#{@field_name}])
        end

        # The element's name attribute.
        def name_attribute(suffix = nil)
          extra = suffix ? "_#{suffix}" : ''
          %(name="#{name_base}#{extra}")
        end

        # The element's name attribute with array suffix.
        def name_attribute_multi
          %(name="#{name_base}[]")
        end

        # Styling for a field in error. Returns nil if the field is not in error.
        def error_state(newline: true)
          return unless @page_config.form_errors

          errs = if @field_config[:parent_field]
                   (@page_config.form_errors[@field_config[:parent_field]] || {})[@field_name]
                 else
                   @page_config.form_errors[@field_name]
                 end

          "<span class='brown crossbeams-form-error'>#{newline ? '<br>' : ''}#{errs.compact.join('; ')}</span>" if errs
        end

        # Render hint text associated with the field.
        def hint_text
          return '' unless @field_config[:hint]

          <<~HTML
            <div style="display:none" data-cb-hint="#{@page_config.name}_#{@field_name}">
              #{@field_config[:hint]}
            </div>
          HTML
        end

        # Render the icon to be clicked to display hint text.
        def hint_trigger
          return '' unless @field_config[:hint]

          Icon.render(:question,
                      css_class: 'ml1 blue pointer',
                      attrs: [
                        'title="Click for hint"',
                        "data-cb-hint-for='#{@page_config.name}_#{@field_name}'"
                      ])
        end

        # Return behaviour rules for rendering.
        def behaviours # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          rules = @page_config.options[:behaviours]
          return nil if rules.nil?

          res = []
          rules.each do |element|
            element.each do |field, rule|
              res << build_behaviour(rule) if field == @field_name
            end
          end
          return nil if res.empty?

          keys = res.map { |r| r[/\A.+=/].chomp('=') }
          raise ArgumentError, "Renderer: cannot have more than one of the same behaviour for field \"#{@field_name}\"" unless keys.length == keys.uniq.length

          res.join(' ')
        end

        private

        def build_behaviour(rule) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          return %(data-change-values="#{split_change_affects(rule[:change_affects])}") if rule[:change_affects]
          return %(data-enable-on-values="#{rule[:enable_on_change].join(',')}") if rule[:enable_on_change]
          return %(data-observe-selected=#{build_observe_selected(rule[:populate_from_selected])}) if rule[:populate_from_selected]
          return %(data-observe-change=#{build_observe_change(rule[:notify])}) if rule[:notify]
          return %(data-observe-keyup=#{build_observe_change(rule[:keyup])}) if rule[:keyup]
          return %(data-observe-input-change=#{build_observe_change(rule[:input_change])}) if rule[:input_change]
          return %(data-observe-lose-focus=#{build_observe_change(rule[:lose_focus])}) if rule[:lose_focus]
        end

        def split_change_affects(change_affects)
          change_affects.split(';').map { |c| "#{@page_config.name}_#{c}" }.join(',')
        end

        def build_observe_change(notify_rules)
          combined = notify_rules.map do |rule|
            %({"url":"#{rule[:url]}","param_keys":#{param_keys_str(rule)},"param_values":{#{param_values_str(rule)}}})
          end.join(',')
          %('[#{combined}]')
        end

        def build_observe_selected(selected_rules)
          combined = selected_rules.map do |rule|
            %({"sortable":"#{rule[:sortable]}"})
          end.join(',')
          %('[#{combined}]')
        end

        def param_keys_str(rule)
          rule[:param_keys].nil? || rule[:param_keys].empty? ? '[]' : %(["#{rule[:param_keys].join('","')}"])
        end

        def param_values_str(rule)
          rule[:param_values].map { |k, v| "\"#{k}\":\"#{v}\"" }.join(',')
        end

        def parent_hash
          @page_config.form_object[@field_config[:parent_field].to_sym] || {}
        end

        def parent_form_values_hash
          @page_config.form_values[@field_config[:parent_field].to_sym] || {}
        end
      end
    end
  end
end
