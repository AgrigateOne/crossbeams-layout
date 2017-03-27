module Crossbeams
  module Layout
    module Renderer
      class Checkbox
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || field_name
        end

        def render
          attrs = []
          # attrs << "size=\"#{@field_config[:length]}\"" if @field_config[:length] 
          # attrs << 'step="any"' if @field_config[:subtype] == :numeric
          # tp = case @field_config[:subtype]
          #      when :integer
          #        'number'
          #      when :numeric
          #        'number'
          #      else
          #        'text'
          #      end
# <input type=checkbox value=a name=checked checked>
# <td valign="top" id="for_supplier_account_sale_cell">
# <input id="cost_code_for_supplier_account_sale" name="cost_code[for_supplier_account_sale]" type="checkbox" value="1">
# <input name="cost_code[for_supplier_account_sale]" type="hidden" value="0">
# </td>
          val = @page_config.form_object.send(@field_name)
          checked = (val && val != false && val != 'f' && val != 'false' && val.to_s != '0') ? 'checked' : ''
          <<-EOS
          <div class="field pure-control-group">
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}</label>
            <input type="checkbox" value="1" #{checked} name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.join(' ')}>
            <input name="#{@page_config.name}[#{@field_name}]" type="hidden" value="0">
          </div>
          EOS
        end
      end
    end
  end
end

