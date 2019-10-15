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

        def render # rubocop:disable Metrics/AbcSize
          datalist = build_datalist
          date_related_value_getter

          <<-HTML
          <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}#{copy_prefix}
            <input type="#{input_type}" value="#{CGI.escapeHTML(value.to_s)}" #{name_attribute} #{field_id} #{attr_list(datalist).join(' ')}>#{copy_suffix}
            <label for="#{@page_config.name}_#{@field_name}">#{@caption}#{error_state}#{hint_trigger}</label>
            #{datalist}
          </div>
          HTML
        end

        private

        def copy_prefix
          return '' unless @field_config[:copy_to_clipboard]

          '<div class="cbl-copy-wrapper">'
        end

        def copy_suffix
          return '' unless @field_config[:copy_to_clipboard]

          %(<button type="button" id="#{id_base}_clip" class="cbl-clipcopy" data-clipboard="copy" title="Copy to clipboard">
          #{Icon.render(:copy, attrs: ["id='#{id_base}_clip_i'", 'data-clipboard="copy"'])}
            </button></div>)
        end

        def subtype
          @field_config[:subtype] || @field_config[:renderer]
        end

        def input_type # rubocop:disable Metrics/CyclomaticComplexity
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
          date: lambda { |d|
            return '' if d.nil?

            d.is_a?(String) ? d : d.strftime('%Y-%m-%d')
          },
          time: lambda { |t|
            return '' if t.nil?

            t.is_a?(String) ? t : t.strftime('%H:%M')
          },
          month: lambda { |d|
            return '' if d.nil?

            d.is_a?(String) ? d : d.strftime('%Y-%m')
          },
          datetime_with_seconds: lambda { |t|
            return '' if t.nil?

            t.is_a?(String) ? t : t.strftime('%Y-%m-%dT%H:%M:%S.%L')
          },
          datetime: lambda { |t|
            return '' if t.nil?

            t.is_a?(String) ? t : t.strftime('%Y-%m-%dT%H:%M')
          }
        }.freeze

        def date_related_value_getter
          @value_getter = if subtype == :datetime && @field_config[:with_seconds] && @field_config[:with_seconds] == true
                            DATE_VALUE_GETTERS[:datetime_with_seconds]
                          else
                            DATE_VALUE_GETTERS[subtype]
                          end
        end

        def value
          res = form_object_value
          res = override_with_form_value(res)
          if res.is_a?(BigDecimal) # TODO: read other frameworks to see best way of handling this...
            res.to_s('F')
          else
            @value_getter.nil? ? res : @value_getter.call(res)
          end
        end

        def build_datalist
          return nil unless @field_config[:datalist] && !@field_config[:datalist].empty?

          s = +''
          @field_config[:datalist].each do |opt|
            s << "<option value=\"#{opt}\">\n"
          end
          <<-HTML
          <datalist id="#{id_base}_listing">
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
                  when :ipv4_address
                    # '((^|\.)((25[0-5])|(2[0-4]\d)|(1\d\d)|([1-9]?\d))){4}$'
                    '^(?:(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(\.(?!$)|$)){4}$'
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
      end
    end
  end
end
