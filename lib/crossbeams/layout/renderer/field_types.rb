module Crossbeams
  module Layout
    module Renderer
      # Rules for which renderer to use for each field type.
      class FieldTypes
        BUILT_IN_RENDERERS = {
          checkbox: Renderer::Checkbox,
          email: Renderer::Input,
          hidden: Renderer::Hidden,
          integer: Renderer::Input,
          label: Renderer::Label,
          number: Renderer::Input,
          numeric: Renderer::Input,
          select: Renderer::Select,
          text: Renderer::Input,
          url: Renderer::Input
        }.freeze
      end
    end
  end
end
