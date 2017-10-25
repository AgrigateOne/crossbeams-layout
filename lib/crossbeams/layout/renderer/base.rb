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

        def build_behaviour(rule)
          return %(data-change-values="#{@page_config.name}_#{rule[:change_affects]}") if rule[:change_affects]
          return %(data-enable-on-values="#{rule[:enable_on_change].join(',')}") if rule[:enable_on_change]
        end
      end
    end
  end
end
