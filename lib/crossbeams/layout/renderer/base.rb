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
          if @page_config.form_errors && @page_config.form_errors[@field_name]
            "<br><span class='crossbeams-form-error'>#{@page_config.form_errors[@field_name].join('; ')}</span>"
          end
        end
      end
    end
  end
end
