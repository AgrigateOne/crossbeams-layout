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
          attrs << 'step="any"' if subtype == :numeric
          tp = case subtype
               when :integer, :numeric, :number
                 'number'
               when :email
                 'email'
               when :url
                 'url'
               else
                 'text'
               end

          <<-EOS
          <div class="#{div_class}">
            <input type="#{tp}" value="#{CGI::escapeHTML(value)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.join(' ')}>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}</label>
          </div>
          EOS
        end

        private

        def subtype
          @field_config[:subtype] || @field_config[:renderer]
        end

        def value
          res = @page_config.form_object.send(@field_name)
          res = @page_config.form_values[@field_name] if @page_config.form_values
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
