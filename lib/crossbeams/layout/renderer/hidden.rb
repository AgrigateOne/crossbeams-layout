module Crossbeams
  module Layout
    module Renderer
      class Hidden < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          <<-EOS
            <input type="hidden" value="#{@page_config.form_object.send(@field_name)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.join(' ')}>
          EOS
        end
      end
    end
  end
end
