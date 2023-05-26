# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Rules for which renderer to use for each field type.
      class FieldTypes
        BUILT_IN_RENDERERS = {
          checkbox: Renderer::Checkbox,
          date: Renderer::Input,
          datetime: Renderer::Datetime,
          email: Renderer::Input,
          file: Renderer::Input,
          hidden: Renderer::Hidden,
          integer: Renderer::Input,
          input: Renderer::Input,
          label: Renderer::Label,
          list: Renderer::List,
          lookup: Renderer::Lookup,
          multi: Renderer::Multi,
          number: Renderer::Input,
          numeric: Renderer::Input,
          radio_group: Renderer::RadioGroup,
          select: Renderer::Select,
          select_multiple: Renderer::SelectMultiple,
          text: Renderer::Input,
          textarea: Renderer::Textarea,
          time: Renderer::Input,
          url: Renderer::Input
        }.freeze
      end
    end
  end
end
