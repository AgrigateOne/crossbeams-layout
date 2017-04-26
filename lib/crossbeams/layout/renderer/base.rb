module Crossbeams
  module Layout
    module Renderer
      # Base class for all field renderers.
      class Base
        def present_field_as_label(field)
          field.to_s.sub(/_id$/, '').split('_').map(&:capitalize).join(' ')
        end
      end
    end
  end
end
