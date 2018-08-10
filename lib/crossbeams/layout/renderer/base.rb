# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Base class for all field renderers.
      class Base
        def present_field_as_label(field)
          field.to_s.sub(/_id$/, '').split('_').map(&:capitalize).join(' ')
        end

        def div_class
          if @page_config.form_errors && @page_config.form_errors[@field_name]
            'crossbeams-field crossbeams-div-error'
          else
            'crossbeams-field'
          end
        end

        def error_state
          "<br><span class='crossbeams-form-error'>#{@page_config.form_errors[@field_name].join('; ')}</span>" if @page_config.form_errors && @page_config.form_errors[@field_name]
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
          Icon.render(:question,
                      css_class: 'ml1',
                      attrs: [
                        'title="Click for hint"',
                        "data-cb-hint-for='#{@page_config.name}_#{@field_name}'"
                      ])
        end

        def behaviours
          rules = @page_config.options[:behaviours]
          return nil if rules.nil?
          res = []
          rules.each do |element|
            element.each do |field, rule|
              res << build_behaviour(rule) if field == @field_name
            end
          end
          return nil if res.empty?
          res.join(' ')
        end

        private

        def build_behaviour(rule)
          return %(data-change-values="#{@page_config.name}_#{rule[:change_affects]}") if rule[:change_affects]
          return %(data-enable-on-values="#{rule[:enable_on_change].join(',')}") if rule[:enable_on_change]
          return %(data-observe-change=#{build_observe_change(rule[:notify])}) if rule[:notify]
          return %(data-observe-selected=#{build_observe_selected(rule[:populate_from_selected])}) if rule[:populate_from_selected]
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
      end
    end
  end
end
