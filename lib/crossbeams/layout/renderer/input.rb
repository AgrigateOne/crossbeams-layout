# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render an input field.
      class Input < Base # rubocop:disable Metrics/ClassLength
        # SC = StylesConfig

        def configure(field_name, field_config, page_config)
          @field_name   = field_name
          @field_config = field_config
          @page_config  = page_config
          @caption      = field_config[:caption] || present_field_as_label(field_name)
        end

        def render # rubocop:disable Metrics/AbcSize
          datalist = build_datalist
          date_related_value_getter
          setup_pattern_title

          # <<-HTML
          # <div #{wrapper_id} class="#{div_class}"#{wrapper_visibility}>#{hint_text}#{copy_prefix}
          #   <input type="#{input_type}" value="#{CGI.escapeHTML(value.to_s)}" #{name_attribute} #{field_id} #{attr_list(datalist).join(' ')}>#{copy_suffix}
          #   <label for="#{id_base}">#{@caption}#{error_state}#{hint_trigger}</label>
          #   #{datalist}
          # </div>
          # HTML

          inpclass = if field_has_errors?
                       SC.css_class(:input_in_err)
                     else
                       SC.css_class(:input)
                     end
          <<-HTML
          <div #{wrapper_id} class="#{div_class}#{wrapper_visibility}">#{hint_text}#{copy_prefix}
            #{label_render(id_base, @caption)}
            <input class="#{inpclass}#{attr_class}" type="#{input_type}" value="#{CGI.escapeHTML(value.to_s)}" #{name_attribute} #{field_id} #{attr_list(datalist).join(' ')}>#{copy_suffix}
            #{error_state}#{datalist}
          </div>
          HTML
          # rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6"
        end
        # <svg xmlns="http://www.w3.org/2000/svg" class="pointer-events-none w-8 h-8 absolute top-1/2 transform -translate-y-1/2 right-3" viewBox="0 0 20 20" fill="currentColor">
        #   <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
        #   <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
        # </svg>

        # <input type="email" name="email" id="email" placeholder="email@kemuscorp.com" class="form-input border border-gray-900 py-3 px-4 bg-white placeholder-gray-400 text-gray-500 appearance-none w-full block pr-14 focus:outline-none">

        private

        # <ag1-financial-input id="price" placeholder="Add Price" class="ng-untouched ng-pristine ng-valid">
        #   <div class="flex items-center relative">
        #     <div class="absolute left-1 top-1/2 -translate-y-1/2 text-french-blue-600 font-medium">
        #       <div class="h-6 w-6 grid place-items-center"> € </div>
        #     </div><!----><!----><!---->
        #     <input type="text" inputmode="decimal" placeholder="Add Price" pattern="^-?\d{1,9}(\.\d{1,10})?$" class="!pl-8 ng-untouched ng-pristine ng-valid">
        #   </div><!---->
        # </ag1-financial-input>

        def copy_prefix
          return '' unless @field_config[:copy_to_clipboard]

          %(<div class="relative">
          <button type="button" id="#{id_base}_clip" class="absolute mt-1 top-1/2 transform -translate-y-1/3 right-3 text-slate-500 hover:text-french-blue-600" viewBox="0 0 20 20" data-clipboard="copy" title="Copy to clipboard">
            #{Icon.render(:copy, attrs: ["id='#{id_base}_clip_i'", 'data-clipboard="copy"'])}
          </button>)
          # %(<div class="flex items-center relative">
          #  <div class="absolute left-1 top-1/2 -translate-y-1/2 text-french-blue-600 font-medium">
          #    <div class="h-6 w-6 grid place-items-center">
          #      #{Icon.render(:copy, attrs: ["id='#{id_base}_clip_i'", 'data-clipboard="copy"'])}
          #    </div>
          #  </div>)
        end

        def copy_suffix
          return '' unless @field_config[:copy_to_clipboard]

          # %(<button type="button" id="#{id_base}_clip" class="cbl-clipcopy" data-clipboard="copy" title="Copy to clipboard">
          # %(<button type="button" id="#{id_base}_clip" class="absolute top-1/2 transform -translate-y-1/2 right-3" viewBox="0 0 20 20" data-clipboard="copy" title="Copy to clipboard">
          # #{Icon.render(:copy, attrs: ["id='#{id_base}_clip_i'", 'data-clipboard="copy"'])}
          #  </button></div>)

          '</div>'
        end

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
          when :date, :month, :time
            date_related_input_type(subtype)
          when :file
            'file'
          else
            'text'
          end
        end

        def date_related_input_type(in_type)
          in_type.to_s
          # case in_type
          # when :date     # yyyy-mm-dd
          #   'date'
          # when :month    # yyyy-mm
          #   'month'
          # when :time     # HH:MM
          #   'time'
          # end
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
          }
        }.freeze

        def date_related_value_getter
          @value_getter = DATE_VALUE_GETTERS[subtype]
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

        PATTERN_REGEX = {
          no_spaces: '[^\s]+',
          valid_filename: '[^\s\/\\\*?:&amp;&quot;<>\|]+',
          lowercase_underscore: '[a-z_]*',
          alphanumeric: '[a-zA-Z0-9]*',
          ipv4_address: '(?:(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(\.(?!$)|$)){4}'
        }.freeze

        PATTERN_TITLES = {
          no_spaces: 'no spaces allowed',
          valid_filename: 'no spaces, asterisks, question marks, greater-than or less-than signs, colons, pipes, quotes, ampersands or slashes allowed',
          lowercase_underscore: 'only alphabetic characters and underscore (_) allowed',
          alphanumeric: 'only alphanumeric characters allowed (a-z and 0-9)',
          ipv4_address: 'must be a valid IP v4 address'
        }.freeze

        def build_pattern(pattern)
          val = case pattern
                when String
                  pattern.sub('/^', '').sub('$/', '')
                when Regexp
                  pattern.inspect.sub('/^', '').sub('$/', '')
                else
                  PATTERN_REGEX[pattern]
                end
          return nil if val.nil?

          "pattern=\"#{val}\""
        end

        def setup_pattern_title
          return if @field_config[:pattern_msg]

          title = PATTERN_TITLES[@field_config[:pattern]]
          @field_config[:pattern_msg] = title unless title.nil?
        end

        def attr_list(datalist) # rubocop:disable Metrics/AbcSize
          [
            attr_class,
            attr_placeholder,
            attr_pattern_title,
            attr_title,
            attr_pattern,
            attr_minvalue,
            attr_maxvalue,
            attr_minlength,
            attr_maxlength,
            attr_readonly,
            attr_disabled,
            attr_required,
            attr_step,
            attr_upper,
            attr_lower,
            attr_accept,
            attr_autofocus,
            behaviours,
            attr_datalist(datalist)
          ].compact
        end

        def attr_class
          # res = ['cbl-input']
          # res << 'cbl-to-upper' if @field_config[:force_uppercase]
          # res << 'cbl-to-lower' if @field_config[:force_lowercase]
          # %(class="#{res.join(' ')}")
          res = []
          res << ' uppercase' if @field_config[:force_uppercase]
          res << ' lowercase' if @field_config[:force_lowercase]
          res << ' pr-10' if @field_config[:copy_to_clipboard]
          res.join(' ')
        end

        def attr_placeholder
          "placeholder=\"#{@field_config[:placeholder]}\"" if @field_config[:placeholder]
        end

        def attr_pattern_title
          "title=\"#{@field_config[:pattern_msg]}\"" if @field_config[:pattern_msg] && !@field_config[:title]
        end

        def attr_title
          "title=\"#{@field_config[:title]}\"" if @field_config[:title]
        end

        def attr_pattern
          build_pattern(@field_config[:pattern]) if @field_config[:pattern]
        end

        def attr_minvalue
          return '' unless @field_config[:minvalue]
          raise ArgumentError, "Input: minvalue is not applicable for type #{input_type}" unless %w[date month week time number range].include?(input_type)

          "min=\"#{@field_config[:minvalue]}\""
        end

        def attr_maxvalue
          return '' unless @field_config[:maxvalue]
          raise ArgumentError, "Input: maxvalue is not applicable for type #{input_type}" unless %w[date month week time number range].include?(input_type)

          "max=\"#{@field_config[:maxvalue]}\""
        end

        def attr_minlength
          return '' unless @field_config[:minlength]
          raise ArgumentError, "Input: minlength is not applicable for type #{input_type}" unless %w[text search url tel email password].include?(input_type)

          "minlength=\"#{@field_config[:minlength]}\""
        end

        def attr_maxlength
          return '' unless @field_config[:maxlength]
          raise ArgumentError, "Input: maxlength is not applicable for type #{input_type}" unless %w[text search url tel email password].include?(input_type)

          "maxlength=\"#{@field_config[:maxlength]}\""
        end

        def attr_readonly
          'readonly="true"' if @field_config[:readonly] && @field_config[:readonly] == true
        end

        def attr_disabled
          'disabled="true"' if @field_config[:disabled] && @field_config[:disabled] == true
        end

        def attr_required
          'required="true"' if @field_config[:required] && @field_config[:required] == true
        end

        def attr_step
          'step="any"' if subtype == :numeric
        end

        def attr_upper
          %{onblur="this.value = this.value.toUpperCase()"} if @field_config[:force_uppercase]
        end

        def attr_lower
          %{onblur="this.value = this.value.toLowerCase()"} if @field_config[:force_lowercase]
        end

        def attr_accept
          %(accept="#{@field_config[:accept]}") if @field_config[:accept]
        end

        def attr_autofocus
          'autofocus' if @field_config[:autofocus]
        end

        def attr_datalist(datalist)
          %(list="#{@page_config.name}_#{@field_name}_listing") unless datalist.nil?
        end
      end
    end
  end
end
