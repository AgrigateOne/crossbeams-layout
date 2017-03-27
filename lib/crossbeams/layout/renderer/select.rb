module Crossbeams
  module Layout
    module Renderer
      class Select
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || field_name
        end

        def render
          attrs = [] # For class, prompt etc...
          if @field_config[:selected]
            sel = @field_config[:selected]
          else
            sel = @page_config.form_object.send(@field_name)
          end
          <<-EOS
          <div class="field pure-control-group">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
            <select #{attrs.join(' ')}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}">
            #{make_options(@field_config[:options], sel)}
            </select>
          </div>
          EOS
        end

        private
        def make_options(ar, selected=nil)
          ar.map do |a|
            if a.kind_of?(Array)
              sel = a.last == selected ? ' selected ' : ''
              "<option value=\"#{a.last}\"#{sel}>#{a.first}</option>"
            else
              sel = a == selected ? ' selected ' : ''
              "<option value=\"#{a}\"#{sel}>#{a}</option>"
            end
          end.join("\n")
        end
      end
    end
  end
end

