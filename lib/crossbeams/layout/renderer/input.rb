# frozen_string_literal: true

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
          attrs << 'class="cbl-input"'
          attrs << "size=\"#{@field_config[:length]}\"" if @field_config[:length]
          attrs << build_pattern(@field_config[:pattern]) if @field_config[:pattern]
          attrs << "title=\"#{@field_config[:pattern_msg]}\"" if @field_config[:pattern_msg]
          attrs << "placeholder=\"#{@field_config[:placeholder]}\"" if @field_config[:placeholder]
          attrs << "title=\"#{@field_config[:title]}\"" if @field_config[:title]
          attrs << 'step="any"' if subtype == :numeric
          attrs << "disabled" if @field_config[:disabled]
          datalist = build_datalist
          attrs << %Q{list="#{@page_config.name}_#{@field_name}_listing"} unless datalist.nil?
          tp = case subtype
               when :integer, :numeric, :number
                 'number'
               when :email
                 'email'
               when :url
                 'url'
               when :date     # yyyy-mm-dd
                 @value_getter = lambda { |d| d.strftime('%Y-%m-%d')}
                 'date'
               when :datetime # yyyy-mm-ddTHH:MM or yyyy-mm-ddTHH:MM:SS.S
                 @value_getter = if @field_config[:with_seconds] && @field_config[:with_seconds] == true
                                   lambda { |t| t.strftime('%Y-%m-%dT%H:%M:%S.%L') }
                                 else
                                   lambda { |t| t.strftime('%Y-%m-%dT%H:%M') }
                                 end
                 'datetime-local'
               when :month    # yyyy-mm
                 @value_getter = lambda { |d| d.strftime('%Y-%m')}
                 'month'
               when :time     # HH:MM
                 @value_getter = lambda { |t| t.strftime('%H:%M') }
                 'time'
               else
                 'text'
               end

          <<-EOS
          <div class="#{div_class}">
            <input type="#{tp}" value="#{CGI::escapeHTML(value.to_s)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attrs.compact.join(' ')}>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}</label>
            #{datalist}
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
            @value_getter.nil? ? res : @value_getter.call(res)
          end
        end

        def build_datalist
          return nil unless @field_config[:datalist] && !@field_config[:datalist].empty?
          s = String.new
          @field_config[:datalist].each do |opt|
            s << "<option value=\"#{opt}\">\n"
          end
          <<-EOS
          <datalist id="#{@page_config.name}_#{@field_name}_listing">
            #{s}
          </datalist>
          EOS
        end

        def build_pattern(pattern)
          if pattern.is_a? String
            val = pattern
          else
            val = case pattern
                  when :no_spaces
                    '[^\s]+'
                  when :lowercase_underscore
                    '[a-z_]'
                  else
                    nil
                  end
          end
          return nil if val.nil?
          "pattern=\"#{val}\""
        end
      end
    end
  end
end
