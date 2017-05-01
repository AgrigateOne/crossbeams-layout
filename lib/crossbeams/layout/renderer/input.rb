module Crossbeams
  module Layout
    module Renderer
      # Render an input field.
      class Input < Base
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          attrs = []
          attrs << "size=\"#{@field_config[:length]}\"" if @field_config[:length]
          attrs << 'step="any"' if @field_config[:subtype] == :numeric
          tp = case @field_config[:subtype]
               when :integer
                 'number'
               when :numeric
                 'number'
               else
                 'text'
               end

          <<-EOS
          <div class="crossbeams-field">
            <input type="#{tp}" value="#{value}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.join(' ')}>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
          </div>
          EOS
        end

        private

        def value
          res = @page_config.form_object.send(@field_name)
          if res.is_a?(BigDecimal) # TODO: read other frameworks to see best way of handling this...
            res.to_s('F')
          else
            res
          end
        end
      end
    end
  end
end
