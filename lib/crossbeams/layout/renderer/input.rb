# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render an input field.
      class Input < Base # rubocop:disable Metrics/ClassLength
        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render
          datalist = build_datalist
          date_related_value_getter

          <<-HTML
          <div class="#{div_class}">#{hint_text}
            <input type="#{input_type}" value="#{CGI.escapeHTML(value.to_s)}" name="#{@page_config.name}[#{@field_name}]" id="#{@page_config.name}_#{@field_name}" #{attr_list(datalist).join(' ')}>
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
            #{datalist}
          </div>
          HTML
        end

        private

        def subtype
          @field_config[:subtype] || @field_config[:renderer]
        end

        def input_type
          case subtype
          when :integer, :numeric, :number
            'number'
          when :email
            'email'
          when :url
            'url'
          when :password
            'password'
          when :date, :datetime, :month, :time
            date_related_input_type(subtype)
          when :file
            'file'
          else
            'text'
          end
        end

        def date_related_input_type(in_type)
          case in_type
          when :date     # yyyy-mm-dd
            'date'
          when :datetime # yyyy-mm-ddTHH:MM or yyyy-mm-ddTHH:MM:SS.S
            'datetime-local'
          when :month    # yyyy-mm
            'month'
          when :time     # HH:MM
            'time'
          end
        end

        DATE_VALUE_GETTERS = {
          date: ->(d) { d.strftime('%Y-%m-%d') },
          time: ->(t) { t.strftime('%H:%M') },
          month: ->(d) { d.strftime('%Y-%m') }
        }.freeze

        def date_related_value_getter
          @value_getter = if subtype == :datetime
                            if @field_config[:with_seconds] && @field_config[:with_seconds] == true
                              ->(t) { t.strftime('%Y-%m-%dT%H:%M:%S.%L') }
                            else
                              ->(t) { t.strftime('%Y-%m-%dT%H:%M') }
                            end
                          else
                            DATE_VALUE_GETTERS[subtype]
                          end
        end

        def value
          res = @page_config.form_object[@field_name]
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
          <<-HTML
          <datalist id="#{@page_config.name}_#{@field_name}_listing">
            #{s}
          </datalist>
          HTML
        end

        def build_pattern(pattern)
          val = if pattern.is_a? String
                  pattern
                else
                  case pattern
                  when :no_spaces
                    '[^\s]+'
                  when :lowercase_underscore
                    '[a-z_]'
                  end
                end
          return nil if val.nil?
          "pattern=\"#{val}\""
        end

        def attr_list(datalist) # rubocop:disable Metrics/AbcSize
          [
            attr_class,
            attr_placeholder,
            attr_pattern_title,
            attr_title,
            attr_pattern,
            attr_minlength,
            attr_maxlength,
            attr_readonly,
            attr_disabled,
            attr_required,
            attr_step,
            attr_upper,
            attr_lower,
            attr_accept,
            behaviours,
            attr_datalist(datalist)
          ].compact
        end

        def attr_class
          res = ['cbl-input']
          res << 'cbl-to-upper' if @field_config[:force_uppercase]
          res << 'cbl-to-lower' if @field_config[:force_lowercase]
          %(class="#{res.join(' ')}")
        end

        def attr_placeholder
          return "placeholder=\"#{@field_config[:placeholder]}\"" if @field_config[:placeholder]
        end

        def attr_pattern_title
          return "title=\"#{@field_config[:pattern_msg]}\"" if @field_config[:pattern_msg] && !@field_config[:title]
        end

        def attr_title
          return "title=\"#{@field_config[:title]}\"" if @field_config[:title]
        end

        def attr_pattern
          return build_pattern(@field_config[:pattern]) if @field_config[:pattern]
        end

        def attr_minlength
          return "minlength=\"#{@field_config[:minlength]}\"" if @field_config[:minlength]
        end

        def attr_maxlength
          return "maxlength=\"#{@field_config[:maxlength]}\"" if @field_config[:maxlength]
        end

        def attr_readonly
          return 'readonly="true"' if @field_config[:readonly] && @field_config[:readonly] == true
        end

        def attr_disabled
          return 'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
        end

        def attr_required
          return 'required="true"' if @field_config[:required] && @field_config[:required] == true
        end

        def attr_step
          return 'step="any"' if subtype == :numeric
        end

        def attr_upper
          return %{onblur="this.value = this.value.toUpperCase()"} if @field_config[:force_uppercase]
        end

        def attr_lower
          return %{onblur="this.value = this.value.toLowerCase()"} if @field_config[:force_lowercase]
        end

        def attr_accept
          return %(accept="#{@field_config[:accept]}") if @field_config[:accept]
        end

        def attr_datalist(datalist)
          %(list="#{@page_config.name}_#{@field_name}_listing") unless datalist.nil?
        end

        def hint_text
          return '' unless @field_config[:hint]
          <<~HTML
            <div style="display:none" data-cb-hint="#{@page_config.name}_#{@field_name}">
              #{@field_config[:hint]}
            </div>
          HTML
        end

        def hint_trigger
          return '' unless @field_config[:hint]
          %( <i class="fa fa-question-circle" title="Click for hint" data-cb-hint-for="#{@page_config.name}_#{@field_name}"></i>)
        end
      end
    end
  end
end
