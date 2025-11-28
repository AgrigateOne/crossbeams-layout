# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Renders a Field by calling the relevant renderer.
      class FieldFactory
        attr_reader :name, :field_config

        def initialize(field_name, field_config, page_config)
          @field_name   = field_name
          @page_config  = page_config || {}
          @field_config = field_config || {}
          raise Crossbeams::Layout::Error, '":render" is not a valid option for a field - use ":renderer instead"' if @field_config.key?(:render)
        end

        def render
          renderer = make_renderer(@field_config[:renderer])
          renderer.configure(@field_name, @field_config, @page_config)
          renderer.render
        end

        private

        def make_renderer(renderer = nil)
          case renderer
          when nil
            Input.new
          when Symbol
            FieldTypes::BUILT_IN_RENDERERS[renderer].new
          else
            renderer
          end
        end
      end
    end
  end
end
