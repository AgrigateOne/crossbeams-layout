# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Rules for which renderer to use for each field type.
      class FieldTypes
        BUILT_IN_RENDERERS = {
          checkbox: Renderer::Checkbox,
          email: Renderer::Input,
          file: Renderer::Input,
          hidden: Renderer::Hidden,
          integer: Renderer::Input,
          label: Renderer::Label,
          multi: Renderer::Multi,
          number: Renderer::Input,
          numeric: Renderer::Input,
          select: Renderer::Select,
          text: Renderer::Input,
          textarea: Renderer::Textarea,
          url: Renderer::Input
        }.freeze
      end
    end
  end
end
