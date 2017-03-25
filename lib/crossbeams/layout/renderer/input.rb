module Crossbeams
  module Layout
    module Renderer
      class Input
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || field_name
        end

        def render
        <<-EOS
      <div class="field pure-control-group">
        <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
        <input type="text" value="#{@page_config.form_object.send(@field_name)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}">
      </div>
        EOS
        end
      end
    end
  end
end
