# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Form for rendering on an RMD page
    class RMDForm
      attr_reader :nodes, :form_action, :multipart, :small_submit, :form_errors, :form_values, :csrf_tag, :rules

      SC = StylesConfig

      def initialize
        @nodes = []
        @form_values = {}
        @form_errors = {}
        @form_lookups = {}
        @buttons = []
        @links = []
        @rules = []
        @multipart = false
        @small_submit = false
        @no_submit = false
        @button_caption = 'Submit'
        @csrf_tag = nil
      end

      def values(value)
        @form_values = value
      end

      def errors(value)
        @form_errors = value
      end

      def name(value)
        @form_name = value
      end

      def button_caption(value)
        @button_caption = value
      end

      def small_submit!
        @small_submit = true
      end

      def no_submit!
        @no_submit = true
      end

      def form_lookups(value)
        @form_lookups = value || {}
      end

      def scan_with_camera(value)
        @scan_with_camera = value
      end

      def invisible?
        false
      end

      def add_csrf_tag(tag)
        @csrf_tag = tag
      end

      def action(act)
        @form_action = act
      end

      def progress(value)
        @progress = value
      end

      def render
        raise ArgumentError, 'RMDForm: no CSRF tag provided' if csrf_tag.nil?

        # <<~HTML
        #  <h1 class="#{SC.css_class(:h1)}">#{caption}#{page_number_and_page_count}</h1>
        #  <form action="#{action}" method="POST" #{"enctype='multipart/form-data'" if @multipart}>
        #    #{error_section}
        #    #{notes_section}
        #    #{camera_section}
        #    #{csrf_tag}
        #    #{field_renders}
        #    #{submit_section}
        #  </form>
        #  #{progress_section}
        #  <div id="txtShow" class="mt-3 bg-blue-100 text-ocean-800 rounded p-3 w-full"></div>
        # HTML
        <<~HTML
          <form action="#{form_action}" method="POST" #{"enctype='multipart/form-data'" if multipart}>
            #{error_section}
            #{camera_section}
            #{csrf_tag}
            #{field_renders}
            #{submit_section}
          </form>
            #{progress_section}
          <div id="txtShow" class="mt-3 bg-blue-100 text-ocean-800 rounded p-3 w-full"></div>
        HTML
      end

      # Add a field to the form.
      # The field will render as an input with name = FORM_NAME[FIELD_NAME]
      # and id = FORM_NAME_FIELD_NAME.
      #
      # @param name [symbol] the name of the form field.
      # @param label [string] the caption for the label to appear beside the input.
      # @param options (Hash) options for the field
      # @option options [Boolean] :required Is the field required? Defaults to true.
      # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
      # @option options [String] :data_type the input type. Defaults to 'text'.
      # @option options [Integer] :minvalue the minimum value allowed in the input.
      # @option options [Integer] :maxvalue the maximum value allowed in the input.
      # @option options [Integer] :width the input with in rem. Defaults to 12.
      # @option options [Boolean] :allow_decimals can a data_type="number" input accept decimals?
      # @option options [Boolean] :submit_form Should the form be submitted automatically after a scan result is placed in this field?
      # @option options [Boolean] :submit_form_set Should the form be submitted automatically after a scan result is placed in the last of the set of fields with this option?
      # @option options [String] :scan The type of barcode symbology to accept. e.g. 'key248_all' for any symbology. Omit for input that does not receive a scan result.
      # Possible values are: key248_all (any symbology), key249_3o9 (309), key250_upc (UPC), key251_ean (EAN), key252_2d (2D - QR etc)
      # @option options [Symbol] :scan_type the type of barcode to expect in the field. This must have a matching entry in AppConst::BARCODE_PRINT_RULES.
      # @return [void]
      def add_field(name, options = {}) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
        @current_field = name
        # label = options[:label] || name.to_s.delete_suffix('_id').gsub('_', ' ').capitalize
        label = make_caption(name, options)
        for_scan = options[:scan] ? 'Scan ' : ''
        data_type = options[:data_type] || 'text'
        width = options[:width] || 12
        required = options[:required].nil? || options[:required] ? ' required' : ''
        autofocus = autofocus_for_field(name)
        label_render = %(<span class="#{'requiredlabel' unless required.empty?}">#{label}</span>)
        # if for_scan, render icon in end of input, else normal
        nodes << if options[:scan]
                   <<~HTML
                     <div id="#{@form_name}_#{name}_row" class="mt-2#{initial_visibilty(options)}">#{label_render}<br>
                     <div class="rmdScanFieldGroup flex items-center"><input class="flex-grow p-2 #{field_input_class}#{field_upper_class(options)} rounded-l" id="#{@form_name}_#{name}" type="#{data_type}"#{decimal_or_int(data_type, options)}#{minmax_val(options)} name="#{@form_name}[#{name}]" placeholder="#{for_scan}#{label}"#{scan_opts(options)} #{render_behaviours} style="widaaath:#{width}rem;" value="#{field_value(form_values[name])}"#{required}#{autofocus}#{lookup_data(options)}#{submit_form(options)}#{set_readonly(form_values[name], for_scan)}#{attr_upper(options)}>#{clear_button(for_scan)}</div>#{hidden_scan_type(name, options)}#{lookup_display(name, options)}
                     #{field_error_message}</div>
                   HTML
                 else
                   <<~HTML
                     <div id="#{@form_name}_#{name}_row" class="mt-2#{initial_visibilty(options)}">#{label_render}<br>
                     <div class="rmdScanFieldGroup rounded has-[:focus-within]:border-ocean-700 border border-slate-300"><input class="p-2 #{field_input_class}#{field_upper_class(options)}" id="#{@form_name}_#{name}" type="#{data_type}"#{decimal_or_int(data_type, options)}#{minmax_val(options)} name="#{@form_name}[#{name}]" placeholder="#{for_scan}#{label}"#{scan_opts(options)} #{render_behaviours} style="widaaath:#{width}rem;" value="#{field_value(form_values[name])}"#{required}#{autofocus}#{lookup_data(options)}#{submit_form(options)}#{set_readonly(form_values[name], for_scan)}#{attr_upper(options)}>#{clear_button(for_scan)}</div>#{hidden_scan_type(name, options)}#{lookup_display(name, options)}
                     #{field_error_message}</div>
                   HTML
                 end
      end

      # Add a label field (display-only) to the form.
      # The field will render as a grey box.
      # An optional accompanying hidden input can be rendered:
      #    with name = FORM_NAME[FIELD_NAME]
      #    and id = FORM_NAME_FIELD_NAME.
      #
      # @param name [symbol] the name of the form field.
      # @param label [string] the caption for the label to appear beside the input.
      # @param value [string] the value to be displayed in the label.
      # @param hidden_value [string] the value of the hidden field. If nil, no hidden field will be generated.
      # @param options (Hash) options for the field
      # @option hide_on_load [Boolean] should this element be hidden when the form loads?
      # @option no_bg [Boolean] should this element be rendered without a background colour?
      # @option value_class [String] a string of css class(es) to wrap around the label value.
      # @return [void]
      def add_label(name, value, options = {})
        v_classes = [options[:value_class]]
        # label = options[:label] || name.to_s.delete_suffix('_id').gsub('_', ' ').capitalize
        label = make_caption(name, options)
        hidden_value = options[:hidden_value]
        bg = options[:no_bg] ? '' : 'bg-slate-200 '
        v_classes << "p-2 #{bg}rounded"
        div_css_class = %( class="#{v_classes.compact.join(' ')}")
        nodes << <<~HTML
          <div id="#{@form_name}_#{name}_row" class="mt-2#{initial_visibilty(options)}"><span>#{label}</span>
          <div#{div_css_class} id="#{@form_name}_#{name}_value">#{field_value(value)} &nbsp;</div>#{hidden_label(name, hidden_value)}
          </div>
        HTML
      end

      # TODO: Add disabled_items to select

      # Add a select box to the form.
      # The field will render as an input with name = FORM_NAME[FIELD_NAME]
      # and id = FORM_NAME_FIELD_NAME.
      #
      # @param name [symbol] the name of the form field.
      # @param label [string] the caption for the label to appear beside the select.
      # @param options (Hash) options for the field
      # @option options [Boolean] :required Is the field required? Defaults to true.
      # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
      # @option options [String] :value the selected value.
      # @option options [String,Boolean] :prompt if true, display a generic prompt. If a string, display the string as prompt.
      # @option options [Array,Hash] :items the select options.
      # @return [void]
      def add_select(name, options = {}) # rubocop:disable Metrics/AbcSize
        @current_field = name
        label = make_caption(name, options)
        required = options[:required].nil? || options[:required] ? ' required' : ''
        items = options[:items] || []
        autofocus = autofocus_for_field(name)
        value = form_values[name] || options[:value]
        label_render = %(<span class="#{'requiredlabel' unless required.empty?}">#{label}</span>)
        nodes << <<~HTML
          <div id="#{@form_name}_#{name}_row" class="mt-2#{initial_visibilty(options)}"#{field_error_state}>#{label_render}#{field_error_message}<br>
          <select class="py-2 px-3 #{Crossbeams::Layout::StylesConfig.css_class(:rmd_select)}#{field_error_class} w-full h-fit" id="#{@form_name}_#{name}" name="#{@form_name}[#{name}]" #{required}#{autofocus} #{render_behaviours}>
            #{make_prompt(options[:prompt])}#{build_options(items, value)}
          </select>
          </div>
        HTML
      end

      # Add a toggle (checkbox) field to the form.
      # The field will render as a toggle with name = FORM_NAME[FIELD_NAME]
      # and id = FORM_NAME_FIELD_NAME.
      # The value returned in params is 't' or 'f'.
      #
      # @param name [symbol] the name of the form field.
      # @param label [string] the caption for the label to appear beside the input.
      # @param options (Hash) options for the field
      # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
      # @return [void]
      def add_toggle(name, options = {})
        label = make_caption(name, options)
        @current_field = name
        nodes << <<~HTML
          <div id="#{@form_name}_#{name}_row" class="mt-2 flex items-center#{initial_visibilty(options)}"#{field_error_state}>
              <input name="#{@form_name}[#{name}]" type="hidden" value="f">
            <label class="switch">
              <input type="checkbox" class="pa2#{field_error_class} toggleCheck" id="#{@form_name}_#{name}" name="#{@form_name}[#{name}]" #{render_behaviours} value="t"#{checked(field_value(form_values[name]))}><span class="slider round"></span>
            </label>
            <label class="ml-3 cursor-pointer" for="#{@form_name}_#{name}">#{label}</label>#{field_error_message}
          </div>
        HTML
      end

      # Render a section caption in bold that takes up the width of the table.
      #
      # @param caption [string] the caption for the section.
      # @param options (Hash) options for the header
      # @option options [String] :id the DOM id of the element
      # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
      # @return [void]
      def add_section_header(caption, options = {})
        raise ArgumentError, 'Section header caption cannot be blank' if caption.nil_or_empty?

        id = options[:id] || "sh_#{caption.hash}"
        nodes << <<~HTML
          <div id="#{id}" class="mt-2#{initial_visibilty(options)}">
            <span class="font-semibold text-slate-600">#{caption}</span>
          </div>
        HTML
      end

      # Render "previous" and "next" buttons.
      #
      # @param url [String] the url with "$:id$" in the place to put the next/prev id.
      # @param ids [Array] the id numbers in desired sequence.
      # @param current_id [Integer] the id in the URL of the current page.
      # @param options (Hash) options for the navigation buttons.
      # @option options [String] :prev_caption The caption to show on the previous button. Default "Previous"
      # @option options [String] :next_caption The caption to show on the next button. Default "Next"
      # @return [void]
      def add_prev_next_nav(url, ids, current_id, options = {}) # rubocop:disable Metrics/AbcSize
        curr_index = ids.index(current_id)
        have_prev = curr_index.positive?
        have_next = curr_index < ids.length - 1
        p_caption = options[:prev_caption] || 'Previous'
        n_caption = options[:next_caption] || 'Next'
        prev = if have_prev
                 %(<a href="#{url.sub('$:id$', ids[curr_index - 1].to_s)}" class="#{SC.css_class(:button_tertiary)}">&laquo; #{p_caption}</a>)
               else
                 '&nbsp;'
               end
        nex = if have_next
                %(<a href="#{url.sub('$:id$', ids[curr_index + 1].to_s)}" class="#{SC.css_class(:button_tertiary)}">#{n_caption} &raquo;</a>)
              else
                '&nbsp;'
              end
        nodes << <<~HTML
          <div class="flex">
            #{prev} #{nex}
          </div>
        HTML
      end

      # Start an HTML table
      #
      # @return [void]
      def add_table_start
        nodes << %(<div class="#{SC.css_class(:rmd_table_div)}"><table class="#{SC.css_class(:rmd_table)}"><tbody>)
      end

      # End an HTML table
      #
      # @return [void]
      def add_table_end
        nodes << '</tbody></table></div>'
      end

      # Add a row of 1 or 2 cells to a table. (an optional label cell and a value cell)
      # `add_table_start` must be called before any rows are added, and `add_table_end` after all rows have been added.
      #
      # @param name [string] the name (DOM id) of the row.
      # @param label [string] the label
      # @param value [string] the value
      # @param hidden_value [string] optional value to be POSTed with the form
      # @param options [hash] options for the row
      # @option options [boolean] :even should this row be shaded with a background?
      # @option options [string] :value_class extra class(es) to apply to the value cell
      # @option options [boolean] :value_only does the row contain only a value? (no label cell)
      # @option hide_on_load [Boolean] should this element be hidden when the form loads?
      def add_table_label(name, value, options = {}) # rubocop:disable Metrics/AbcSize
        label = make_caption(name, options)
        tr_css = options[:even] ? SC.css_class(:rmd_table_row_even) : SC.css_class(:rmd_table_row_odd)
        value = '&nbsp;' if value == ''
        v_classes = [options[:value_class]]
        v_classes << 'p-2'
        div_css_class = %( class="#{v_classes.compact.join(' ')}")
        col_head = options[:value_only] ? '' : %(<td class="#{SC.css_class(:rmd_table_td_label)}">#{label}</td>)
        nodes << <<~HTML
          <tr id="#{@form_name}_#{name}_row" class="#{tr_css}#{initial_visibilty(options)}">#{col_head}
            <td class="#{SC.css_class(:rmd_table_td_value)}"><div#{div_css_class} id="#{@form_name}_#{name}_value">#{field_value(value) || '&nbsp;'}#{hidden_label(name, options[:hidden_value])}</div>
          </td></tr>
        HTML
      end

      # Add a row to a table. (any number of cells)
      # `add_table_start` must be called before any rows are added, and `add_table_end` after all rows have been added.
      #
      # @param name [string] the name (DOM id) of the row.
      # @param cols [array] the heading followed by the values
      # @param options [hash] options for the row
      # @option options [boolean] :even should this row be shaded with a background?
      # @option options [boolean] :heading should this row render as a heading row?
      # @option options [boolean] :highlight_first_col should the first column be bold? Default is true.
      # @option options [boolean] :stagger_col1 render the first column in its own row? Use this if the 1st column could be quite wide.
      # @option hide_on_load [Boolean] should this element be hidden when the form loads?
      def add_table_row(name, cols, options = {}) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        tr_css = options[:even] ? SC.css_class(:rmd_table_row_even) : SC.css_class(:rmd_table_row_odd)
        tr_css = SC.css_class(:rmd_table_row_header) if options[:heading]
        td_class = options[:heading] ? SC.css_class(:rmd_table_td_header) : SC.css_class(:rmd_table_td_value)
        high_first = options.fetch(:highlight_first_col, true)
        values = cols.map.with_index do |v, i|
          case v
          when NilClass
            %(<td class="#{td_class}"><div class="p-2">&nbsp;</div></td>)
          when TrueClass
            %(<td class="#{td_class} text-green-500 text-center"><div class="p-2">#{Crossbeams::Layout::Icon.render(:checkon, css_class: 'mr-2 inline')}</div></td>)
          when FalseClass
            %(<td class="#{td_class} text-red-400 text-center"><div class="p-2">#{Crossbeams::Layout::Icon.render(:checkoff, css_class: 'mr-2 inline')}</div></td>)
          else
            if i.zero? && high_first && !options[:heading]
              %(<td class="#{SC.css_class(:rmd_table_td_label)}"><div class="p-2">#{v}</div></td>)
            else
              %(<td class="#{td_class}"><div class="p-2">#{v}</div></td>)
            end
          end
        end

        nodes << if options[:stagger_col1]
                   v1 = values.shift
                   values.unshift(%(<td class="#{SC.css_class(:rmd_table_td_label)}"><div class="p-2">&nbsp;</div></td>))
                   <<~HTML
                     <tr id="#{@form_name}_#{name}_row_h" class="#{tr_css}#{initial_visibilty(options)}">
                     #{v1.sub('td', %(td colspan="#{values.length}"))}
                     </tr>
                     <tr id="#{@form_name}_#{name}_row" class="#{tr_css}#{initial_visibilty(options)}">
                       #{values.join(' ').gsub('border-t', '')}
                     </tr>
                   HTML
                 else
                   <<~HTML
                     <tr id="#{@form_name}_#{name}_row" class="#{tr_css}#{initial_visibilty(options)}">
                       #{values.join(' ')}
                     </tr>
                   HTML
                 end
      end

      # Add a button to the form.
      # This button submits the same form, but to a different url (provided in action param)
      #
      # @param caption [string] the caption for the button.
      # @param action [string] the url target for the form.
      # @param options (Hash) options for the header
      # @option options [String] :id the DOM id of the element
      # @option options [Boolean] :hide_on_load should this element be hidden when the form loads?
      # @return [void]
      def add_button(caption, action, options = {})
        raise ArgumentError, 'Button caption cannot be blank' if caption.nil_or_empty?
        raise ArgumentError, 'Button action cannot be blank' if action.nil_or_empty?

        id = options[:id] || "btn_#{caption.hash}"
        @buttons << <<~HTML
          <button id="#{id}" formaction="#{action}" type="submit" data-disable-with="Processing..." class="grow #{SC.css_class(:rmd_button_secondary)}#{initial_visibilty(options)}" data-rmd-btn="Y">
            #{caption}
          </button>
        HTML
      end

      # Add a row of three "LED"s for red, orange and green (only one colour will be set, the others remain grey.
      # These mimic the LEDs on devices.
      #
      # @param colour [symbol] the colour to "turn on"
      # @return [void]
      def add_status_leds(colour = :green)
        key = { green: 'slate-300', red: 'slate-300', orange: 'slate-300' }
        key[colour] = "#{colour}-600"
        nodes << <<~HTML
          <div class="rmdLeds flex justify">
            <div id="led_red" class="rmdLedLight bg-#{key[:red]}"></div>
            <div id="led_orange" class="rmdLedLight bg-#{key[:orange]}"></div>
            <div id="led_green" class="rmdLedLight bg-#{key[:green]}"></div>
          </div>
        HTML
      end

      def add_link(url, text, options = {})
        hs = { url: url, text: text }
        hs[:prompt] = options[:prompt] if options[:prompt]
        @links << hs
      end

      def add_image(name, options = {})
        label = make_caption(name, options)

        nodes << <<~HTML
          <div class="mt-2 py-2">
            <label for="#{@form_name}_#{name}" class="#{SC.css_class(:rmd_button_secondary)}-button">#{Crossbeams::Layout::Icon.render(:camera, css_class: 'mr-2 inline')} #{label}</label>
            <input id="#{@form_name}_#{name}" type="file" name="#{@form_name}[#{name}]" accept="image/jpeg" capture="environment">
          </div>
        HTML
        @multipart = true
      end

      def behaviours
        raise ArgumentError, 'Behaviours must be defined before fields' unless @nodes.empty?

        yield self
      end

      # ---------------------------------------------------------------------------------------------------
      # BEHAVIOURS - PARTS OF THIS CODE ARE ALSO IN UiRules AND PARTS IN Crossbeams::Layout::Renderer::Base
      # ---------------------------------------------------------------------------------------------------

      # 1) BEHAVIOUR (UiRules)
      # ======================
      def enable(field_to_enable, conditions = {})
        targets = Array(field_to_enable)
        observer = conditions[:when] || raise(ArgumentError, 'Enable behaviour requires `when`.')
        change_values = conditions[:changes_to]
        @rules << { observer => { change_affects: targets.join(';') } }
        targets.each do |target|
          @rules << { target => { enable_on_change: change_values } }
        end
      end

      def dropdown_change(field_name, conditions = {})
        raise(ArgumentError, 'Dropdown change behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

        @rules << { field_name => {
          notify: (conditions[:notify] || []).map do |n|
            {
              url: n[:url],
              param_keys: n[:param_keys] || [],
              param_values: n[:param_values] || {}
            }
          end
        } }
      end

      def populate_from_selected(field_name, conditions = {})
        @rules << { field_name => {
          populate_from_selected: (conditions[:populate_from_selected] || []).map do |p|
            {
              sortable: p[:sortable]
            }
          end
        } }
      end

      def keyup(field_name, conditions = {})
        raise(ArgumentError, 'Key up behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

        @rules << { field_name => {
          keyup: (conditions[:notify] || []).map do |n|
            {
              url: n[:url],
              param_keys: n[:param_keys] || [],
              param_values: n[:param_values] || {}
            }
          end
        } }
      end

      def input_change(field_name, conditions = {})
        raise(ArgumentError, 'Input change behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

        @rules << { field_name => {
          input_change: (conditions[:notify] || []).map do |n|
            {
              url: n[:url],
              param_keys: n[:param_keys] || [],
              param_values: n[:param_values] || {}
            }
          end
        } }
      end

      def lose_focus(field_name, conditions = {})
        raise(ArgumentError, 'Key up behaviour requires `notify: url`.') if (conditions[:notify] || []).any? { |c| c[:url].nil? }

        @rules << { field_name => {
          lose_focus: (conditions[:notify] || []).map do |n|
            {
              url: n[:url],
              param_keys: n[:param_keys] || [],
              param_values: n[:param_values] || {}
            }
          end
        } }
      end

      private

      def field_value(value)
        return value.to_s('F') if value.is_a?(BigDecimal)
        return value.strftime('%Y-%m-%d %H:%M') if value.is_a?(Time) || value.is_a?(DateTime)

        value
      end

      def initial_visibilty(options)
        return '' unless options[:hide_on_load]

        ' hidden'
      end

      def scan_opts(options)
        if options[:scan]
          %( data-scanner="#{options[:scan]}" data-scan-rule="#{options[:scan_type]}" autocomplete="off")
        else
          ''
        end
      end

      def hidden_label(name, hidden_value)
        value = hidden_value || form_values[name]
        return '' if value.nil?

        <<~HTML
          <input id ="#{@form_name}_#{name}" type="hidden" name="#{@form_name}[#{name}]" value="#{field_value(value)}">
        HTML
      end

      def clear_button(for_scan)
        return '' if for_scan.empty?

        <<~HTML
          <button type="button" title="Clear input" class="bg-slate-200 text-slate-700 font-bold py-3 px-4 rounded-r hover:text-#{SC.css_class(:primary_h_colour)} hover:bg-#{SC.css_class(:secondary_h_bg)}" data-rmd-clear="y">
            <svg class="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
            </svg>
          </button>
        HTML
      end

      def submit_form(options)
        return '' unless options[:submit_form] || options[:submit_form_set]

        if options[:submit_form]
          ' data-submit-form="Y"'
        else
          ' data-submit-form-set="Y"'
        end
      end

      def set_readonly(val, for_scan)
        return '' if for_scan.empty?
        return '' if val.nil?

        ' readonly'
      end

      def field_upper_class(options)
        return '' unless options[:force_uppercase]

        ' uppercase'
      end

      def attr_upper(options)
        return '' unless options[:force_uppercase]

        %{ onblur="this.value = this.value.toUpperCase()"}
      end

      def hidden_scan_type(name, options)
        return '' unless options[:scan]

        <<~HTML
          <input id="#{@form_name}_#{name}_scan_field" type="hidden" name="#{@form_name}[#{name}_scan_field]" value="#{form_values["#{name}_scan_field".to_sym]}">
        HTML
      end

      def field_input_class
        val = error_msg_for_field
        if val
          SC.css_class(:input_in_err)
        else
          SC.css_class(:input)
        end
      end

      def error_msg_for_field(field = @current_field)
        return nil unless form_errors[:errors].respond_to?(:key?)

        form_errors[:errors][field]
      end

      def field_error_state
        val = error_msg_for_field
        return '' unless val

        %( class="#{SC.css_class(:note_error)}")
      end

      def field_error_message
        val = error_msg_for_field
        return '' unless val

        %(<span class="#{SC.css_class(:note_error)}">#{val.compact.join('; ')}</span>)
      end

      def field_error_class
        val = error_msg_for_field
        return '' unless val

        ' bg-red-100'
      end

      # False if value is nil, false or starts with f, n or 0.
      # Else true.
      def checked(value)
        false_str = value.to_s.match?(/[nf0]/i)
        value && value != false && !false_str ? ' checked' : ''
      end

      def decimal_or_int(data_type, options)
        return '' unless data_type == 'number'
        return '' unless options[:allow_decimals]

        ' step="any"'
      end

      def minmax_val(options)
        return '' unless options[:minvalue] || options[:maxvalue]

        ar = []
        ar << %( min="#{options[:minvalue]}") if options[:minvalue]
        ar << %( max="#{options[:maxvalue]}") if options[:maxvalue]
        ar.join(' ')
      end

      # Set autofocus on fields in error, or else on the first field.
      def autofocus_for_field(name)
        if form_errors
          if error_msg_for_field(name)
            ' autofocus'
          else
            ''
          end
        else
          nodes.empty? ? ' autofocus' : ''
        end
      end

      def camera_section
        return '' unless @scan_with_camera

        btn_class = SC.css_class(:rmd_button_action)
        <<~HTML
          <div class="mt-4 flex flex-row gap-4 justify-center flex-wrap">
            <button id="cameraScan" type="button" class="hover:opacity-50 grow #{btn_class} py-4">
              #{Crossbeams::Layout::Icon.render(:camera, css_class: 'mr-2 inline')} Scan with camera
            </button>
            <button id="cameraLight" type="button" class="hover:opacity-50 grow #{btn_class} py-4">
              #{Crossbeams::Layout::Icon.render(:show, css_class: 'mr-2 inline')} Light On/Off
            </button>
          </div>
        HTML
      end

      def lookup_data(options)
        return '' unless options[:lookup]

        ' data-lookup="Y"'
      end

      def lookup_display(name, options)
        return '' unless options[:lookup]

        <<~HTML
          <div id ="#{form_name}_#{name}_scan_lookup" class="font-semibold text-slate-400" data-lookup-result="Y" data-reset-value="#{@form_lookups[name] || '&nbsp;'}">#{@form_lookups[name] || '&nbsp;'}</div>
          <input id ="#{form_name}_#{name}_scan_lookup_hidden" type="hidden" data-lookup-hidden="Y" data-reset-value="#{@form_lookups[name] || '&nbsp;'}" name="lookup_values[#{name}]" value="#{@form_lookups[name]}">
        HTML
      end

      def field_renders
        nodes.join("\n")
      end

      def progress_section
        show_hide = @progress ? '' : ' style="display:none"'
        <<~HTML
          <div id="rmd-progress" class="text-white bg-blue-400 border border-blue-900 p-3 mt-1 w-full"#{show_hide}>
            #{@progress}
          </div>
        HTML
      end

      def make_caption(name, options)
        options[:caption] || name.to_s.delete_suffix('_id').gsub('_', ' ').capitalize
      end

      def make_prompt(prompt)
        return '' if prompt.nil?

        str = prompt.is_a?(String) ? prompt : 'Select a value'
        "<option value=\"\">#{str}</option>\n"
      end

      def build_options(list, selected)
        if list.is_a?(Hash)
          opts = []
          list.each do |group, sublist|
            opts << %(<optgroup label="#{group}">)
            opts << make_options(Array(sublist), selected)
            opts << '</optgroup>'
          end
          opts.join("\n")
        else
          make_options(Array(list), selected)
        end
      end

      def make_options(list, selected)
        opts = list.map do |a|
          a.is_a?(Array) ? option_string(a.first, a.last, selected) : option_string(a, a, selected)
        end
        opts.join("\n")
      end

      def option_string(text, value, selected)
        sel = selected && value.to_s == selected.to_s ? ' selected ' : ''
        "<option value=\"#{CGI.escapeHTML(value.to_s)}\"#{sel}>#{CGI.escapeHTML(text.to_s)}</option>"
      end

      def submit_section
        return '' if @no_submit && @links.empty? && @buttons.empty?
        return "<p>#{links_section}</p>" if @no_submit && @buttons.empty?
        return "<p>#{buttons_section} #{links_section}</p>" if @no_submit

        btn_class = @small_submit ? :rmd_button_action : :rmd_button_primary

        div_w = @small_submit ? 'justify-center' : 'justify-end'
        grow = @small_submit ? 'grow ' : ''
        # ------------------------------------
        # Temp for initial test:
        # button_caption = 'Submit'
        submit_id_str = ''
        initial_hide = ''
        # buttons_section = ''
        # links_section = ''
        reset_section = ''
        # ------------------------------------
        <<~HTML
          <div class="mt-4 flex flex-row gap-4 #{div_w} flex-wrap">
            <input type="submit" value="#{@button_caption}" #{submit_id_str}data-disable-with="Submitting..." class="#{grow}#{SC.css_class(btn_class)} py-4#{initial_hide}" data-rmd-btn="Y"> #{buttons_section} #{links_section} #{reset_section}
          </div>
        HTML
      end

      def buttons_section
        return '' if @buttons.empty?

        @buttons.join(' ')
      end

      def error_section
        base_err = base_err_msg_formatted
        err_msg = error_message_formatted

        show_hide = base_err.empty? && err_msg.empty? ? ' hidden' : ''
        <<~HTML
          <div id="rmd-error" class="#{show_hide}">
            #{err_msg} #{base_err}
          </div>
        HTML
      end

      def error_message_formatted
        case form_errors[:error_message]
        when nil
          ''
        else
          if form_errors[:error_message].start_with?('<div')
            form_errors[:error_message]
          else
            Crossbeams::Layout::Notice.new({}, form_errors[:error_message], notice_type: :error, show_caption: false).render
          end
        end
      end

      def base_err_msg_formatted
        base_err = ((form_errors.dig(:errors, :base) || []) + (form_errors.dig(:errors, nil) || [])).join(', ')
        if base_err.empty?
          ''
        else
          Crossbeams::Layout::Notice.new({}, base_err, notice_type: :error, show_caption: false).render
        end
      end

      def links_section
        @links.map do |link|
          caption = link[:text]
          url = link[:url]
          if link[:prompt]
            <<~HTML
              <a href="#{url}" class="#{SC.css_class(:rmd_button_secondary)}" data-prompt="#{link[:prompt]}">#{caption}</a>
            HTML
          else
            <<~HTML
              <a href="#{url}" class="#{SC.css_class(:rmd_button_secondary)}">#{caption}</a>
            HTML
          end
        end.join
      end

      # ---------------------------------------------------------------------------------------------------
      # BEHAVIOURS - PARTS OF THIS CODE ARE ALSO IN UiRules AND PARTS IN Crossbeams::Layout::Renderer::Base
      # ---------------------------------------------------------------------------------------------------

      # 2) BEHAVIOUR (Crossbeams::Layout::Renderer::Base)
      # =================================================

      # Return behaviour rules for rendering.
      def render_behaviours # rubocop:disable Metrics/AbcSize
        return nil if rules.nil?

        res = []
        rules.each do |element|
          element.each do |field, rule|
            res << build_behaviour(rule) if field == @current_field
          end
        end
        return nil if res.empty?

        keys = res.map { |r| r[/\A.+=/].chomp('=') }
        raise ArgumentError, "Renderer: cannot have more than one of the same behaviour for field \"#{@current_field}\"" unless keys.length == keys.uniq.length

        res.join(' ')
      end

      def build_behaviour(rule) # rubocop:disable Metrics/AbcSize
        return %(data-change-values="#{split_change_affects(rule[:change_affects])}") if rule[:change_affects]
        return %(data-enable-on-values="#{rule[:enable_on_change].join(',')}") if rule[:enable_on_change]
        return %(data-observe-selected=#{build_observe_selected(rule[:populate_from_selected])}) if rule[:populate_from_selected]
        return %(data-observe-change=#{build_observe_change(rule[:notify])}) if rule[:notify]
        return %(data-observe-keyup=#{build_observe_change(rule[:keyup])}) if rule[:keyup]
        return %(data-observe-input-change=#{build_observe_change(rule[:input_change])}) if rule[:input_change]

        %(data-observe-lose-focus=#{build_observe_change(rule[:lose_focus])}) if rule[:lose_focus]
      end

      def split_change_affects(change_affects)
        change_affects.split(';').map { |c| "#{form_name}_#{c}" }.join(',')
      end

      def build_observe_change(notify_rules)
        combined = notify_rules.map do |rule|
          %({"url":"#{rule[:url]}","param_keys":#{param_keys_str(rule)},"param_values":{#{param_values_str(rule)}}})
        end.join(',')
        %('[#{combined}]')
      end

      def build_observe_selected(selected_rules)
        combined = selected_rules.map do |rule|
          %({"sortable":"#{rule[:sortable]}"})
        end.join(',')
        %('[#{combined}]')
      end

      def param_keys_str(rule)
        rule[:param_keys].nil? || rule[:param_keys].empty? ? '[]' : %(["#{rule[:param_keys].join('","')}"])
      end

      def param_values_str(rule)
        rule[:param_values].map { |k, v| "\"#{k}\":\"#{v}\"" }.join(',')
      end
    end
  end
end
