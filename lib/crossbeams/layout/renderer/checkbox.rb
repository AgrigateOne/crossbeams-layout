module Crossbeams
  module Layout
    module Renderer
      class Checkbox < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          attrs = []
          val = @page_config.form_object.send(@field_name)
          checked = val && val != false && val != 'f' && val != 'false' && val.to_s != '0' ? 'checked' : ''
          <<-EOS
          <div class="crossbeams-field">
            <input type="checkbox" value="1" #{checked} name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.join(' ')}>
            <input name="#{@page_config.name}[#{@field_name}]" type="hidden" value="0">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
          </div>
          EOS
        end
      end
    end
  end
end
