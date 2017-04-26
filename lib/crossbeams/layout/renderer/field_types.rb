module Crossbeams
  module Layout
    module Renderer
      # Rules for which renderer to use for each field type.
      class FieldTypes
        BUILT_IN_RENDERERS = {
          text: Renderer::Input,
          email: Renderer::Input,
          number: Renderer::Input,
          label: Renderer::Label,
          checkbox: Renderer::Checkbox,
          select: Renderer::Select,
          hidden: Renderer::Hidden
        }.freeze
      end
    end
  end
end
