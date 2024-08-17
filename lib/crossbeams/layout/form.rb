# frozen_string_literal: true

module Crossbeams
  module Layout
    # Form object.
    class Form # rubocop:disable Metrics/ClassLength
      attr_reader :sequence, :nodes, :page_config, :form_action, :form_method,
                  :got_row, :no_row, :csrf_tag, :remote_form, :form_config,
                  :multipart_form, :form_caption, :caption_level, :in_loading_page

      PROGRESS_ICON = <<~HTML
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="2"><path stroke-dasharray="60" stroke-dashoffset="60" stroke-opacity=".3" d="M12 3C16.9706 3 21 7.02944 21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3Z"><animate fill="freeze" attributeName="stroke-dashoffset" dur="1.3s" values="60;0"/></path><path stroke-dasharray="15" stroke-dashoffset="15" d="M12 3C16.9706 3 21 7.02944 21 12"><animate fill="freeze" attributeName="stroke-dashoffset" dur="0.3s" values="15;0"/><animateTransform attributeName="transform" dur="1.5s" repeatCount="indefinite" type="rotate" values="0 12 12;360 12 12"/></path></g></svg>
      HTML

      def initialize(page_config, section_sequence, sequence) # rubocop:disable Metrics/AbcSize
        @section_sequence       = section_sequence
        @sequence               = sequence
        @form_action            = '/' # work out from page_config.object?
        @nodes                  = []
        @buttons                = []
        @page_config            = page_config
        @form_config            = PageConfig.new({}) # OpenStruct.new
        @form_method            = :create
        @remote_form            = false
        @multipart_form         = false
        @view_only              = false
        @inline                 = false
        @got_row                = false
        @no_row                 = false
        @no_submit              = false
        @hidden_submit          = false
        @submit_in_loading_page = false
        @brief_disable          = false
        @grid_filter            = false
        @grid_id                = nil
        @submit_id              = nil
        @csrf_tag               = nil
        @submit_caption         = 'Submit'
        @disable_caption        = 'Submitting'
        @form_caption           = nil
      end

      def form_config=(value)
        @form_config = PageConfig.new(value) # OpenStruct.new
      end

      def add_csrf_tag(tag)
        @csrf_tag = tag
      end

      # Make this a remote (AJAX) form.
      # @returns [void]
      def remote!
        @remote_form = true
      end

      # Make this a multipart form (for uploading files).
      # @returns [void]
      def multipart!
        @multipart_form = true
      end

      # Make this a grid filter form (submit via javascript to refresh a grid)
      # @returns [void]
      def grid_filter!
        @grid_filter = true
      end

      def grid_id(val)
        @grid_id = val
      end

      # Make this form submit to its action in a "loading" page as a GET request.
      # @returns [void]
      def submit_in_loading_page!
        @submit_in_loading_page = true
      end

      # Only disable the submit button briefly after it is pressed.
      # @returns [void]
      def briefly_disable_submit!
        @brief_disable = true
      end

      # Make this a view-only form.
      # @returns [void]
      def view_only!
        @view_only = true
      end

      # This form does not need a submit button.
      # - usually for a view form.
      # @returns [void]
      def no_submit!
        @no_submit = true
      end

      # Render the form with a hidden submit button.
      # - typically for a behaviour to show it later.
      # @returns [void]
      def initially_hide_button
        @hidden_submit = true
      end

      # Provide an id for the submit button.
      # @param value [string] the id value.
      # @returns [void]
      def button_id(value)
        @submit_id = value
      end

      # Include the submit button on the same line as input.
      # @returns [void]
      def inline!
        @inline = true
      end

      def caption(value, level: 2)
        @form_caption = value
        raise ArgumentError, 'Caption level can only be 1, 2, 3 or 4' unless [1, 2, 3, 4].include?(level)

        @caption_level = level
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def action(act)
        @form_action = act
      end

      def form_id(val)
        @dom_id = val
      end

      # --- FROM PAGE FOR OVERRIDE (also need rules, renderer needs to get obj from form, not page)...
      # Register the form object.
      def form_object(obj)
        @form_config.form_object = obj
      end

      # Register the values that have been filled-in on a form.
      def form_values(values)
        @form_config.form_values = values
      end

      # Register the error conditions for a form.
      def form_errors(errors)
        @form_config.form_errors = errors
        return unless errors && errors[:base_with_highlights]

        Array(errors[:base_with_highlights][:highlights]).each do |field|
          @form_config.form_errors[field] ||= []
          @form_config.form_errors[field] << nil
        end
      end
      # --- ...FROM PAGE FOR OVERRIDE

      def method(method)
        raise ArgumentError, "Invalid form method \"#{method}\"" unless %i[create update].include?(method)

        @form_method = method
      end

      def row
        @got_row = true
        raise Error, 'Cannot mix row and non-row text or fields' if no_row

        row = Row.new(config_for_field, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      def expand_collapse(options = {})
        exp_col = ExpandCollapseFolds.new(config_for_field, nodes.length + 1, options)
        @nodes << exp_col
      end

      # Include a fold-up in the form.
      def fold_up
        fold_up = FoldUp.new(config_for_field, nodes.length + 1)
        yield fold_up
        @nodes << fold_up
      end

      def add_field(name, options = {})
        @no_row = true
        raise Error, 'Cannot mix row and fields' if got_row

        @nodes << Field.new(config_for_field, name, options)
      end

      def config_for_field
        @form_config.form_object.nil? ? @page_config : @form_config
      end

      def add_button(button_caption, formaction, options = {})
        @buttons << FormButton.new(button_caption, formaction, options)
      end

      def add_text(text, opts = {})
        @no_row = true
        raise Error, 'Cannot mix row and text' if got_row

        @nodes << Text.new(page_config, text, opts)
      end

      def add_notice(text, opts = {})
        @no_row = true
        raise Error, 'Cannot mix row and text' if got_row

        @nodes << Notice.new(page_config, text, opts)
      end

      def add_list(items, options = {})
        @nodes << List.new(page_config, items, options)
      end

      def add_sortable_list(prefix, items, options = {})
        @nodes << SortableList.new(page_config, prefix, items, options)
      end

      def add_address(addresses, opts = {})
        @nodes << Address.new(page_config, addresses, opts)
      end

      def add_contact_method(contact_methods, options = {})
        @nodes << ContactMethod.new(page_config, contact_methods, options)
      end

      def submit_captions(value, disabled_value = nil)
        @submit_caption = value
        @disable_caption = disabled_value || value
      end

      def render
        renders = sub_renders
        remote_str = remote_form ? ' data-remote="true"' : ''
        multipart_str = multipart_form ? ' enctype="multipart/form-data"' : ''
        submit_markup = if @inline || @no_submit
                          ''
                        else
                          <<~HTML
                            <div class="crossbeams-actions pa2">
                              #{submit_button}
                            </div>
                          HTML
                        end
        <<~HTML
          #{render_caption}<form #{render_id}class="crossbeams-form" #{data_grid_id}#{gridfilter}#{as_loading}action="#{form_action}"#{multipart_str}#{remote_str} accept-charset="utf-8" method="POST">
            #{error_head}
            #{csrf_tag}
            #{form_method_str}
            #{renders}
            #{submit_markup}
          </form>
        HTML
      end

      private

      def as_loading
        return '' unless @submit_in_loading_page

        'data-convert-to-loading="true" '
      end

      def gridfilter
        return '' unless @grid_filter

        'data-grid-filter="true" '
      end

      def data_grid_id
        return '' unless @grid_id

        %(data-grid-id="#{@grid_id}" )
      end

      def form_method_str
        case form_method
        when :create
          ''
        when :update
          '<input type="hidden" name="_method" value="PATCH">'
        end
      end

      def render_caption
        return '' if remote_form || form_caption.nil?

        "<h#{caption_level}>#{form_caption}</h#{caption_level}>\n"
      end

      def render_id
        @dom_id.nil? ? '' : "id='#{@dom_id}' "
      end

      def error_head
        return hidden_form_errors unless page_config.form_errors && (page_config.form_errors[nil] || page_config.form_errors[:base] || page_config.form_errors[:base_with_highlights])

        <<~HTML
          <div class="crossbeams-form-base-error pa1 mb1 bg-washed-red brown">
            <ul class="list"><li>#{base_messages.join('</li><li>')}</li></ul>
          </div>
          #{hidden_form_errors}
        HTML
      end

      def hidden_form_errors
        return '' unless page_config.form_errors

        <<~HTML
          <pre style="display:none">
            VALIDATION ERRORS
            #{page_config.form_errors.inspect}
          </pre>
        HTML
      end

      def base_messages # rubocop:disable Metrics/AbcSize
        messages = page_config.form_errors[nil] || []
        messages += page_config.form_errors[:base] if page_config.form_errors[:base]
        messages += page_config.form_errors[:base_with_highlights][:messages] if page_config.form_errors[:base_with_highlights]
        messages
      end

      def sub_renders
        if got_row
          nodes.reject(&:invisible?).map(&:render).join("\n<!-- End Row -->\n")
        else
          render_nodes_inside_generated_row
        end
      end

      def render_nodes_inside_generated_row
        # wrap nodes in row & cols.
        row = Row.make_row(page_config, sequence, 1)
        col = Column.make_column(page_config)
        nodes.reject(&:invisible?).each do |node|
          col.add_node(node)
        end
        if @inline
          row.add_node(col)
          col = Column.make_column(page_config)
          col.add_node(inline_submit)
        end
        row.add_node(col)
        "#{row.render}\n"
      end

      def submit_button # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        loading = %(<span class="crossbeams-loading-button" hidden>#{PROGRESS_ICON}</span>)
        disabler = @remote_form || @brief_disable ? 'briefly-disable' : 'disable'
        disable_command = @submit_in_loading_page ? '' : %( data-#{disabler}-with="#{@disable_caption}")
        id_str = @submit_id.nil? ? '' : %( id="#{@submit_id}")
        hidden_str = @hidden_submit ? ' hidden' : ''
        extra_buttons = @buttons.map { |b| b.render(@remote_form) }.join("\n")
        if @view_only
          %(<input type="submit"#{id_str} name="commit" value="Close" class="close-dialog white bg-blue br2 dim pa3 ba b--near-white"#{hidden_str}>#{extra_buttons})
        else
          %(<input type="submit"#{id_str} name="commit" value="#{@submit_caption}"#{disable_command} class="white bg-green br2 dim pa3 ba b--near-white"#{hidden_str}>#{loading}#{extra_buttons})
        end
      end

      def inline_submit
        InlineSubmit.new(@view_only, @submit_caption, @disable_caption, @submit_id, @hidden_submit, @remote_form)
      end

      # Render a submit button inline - without surrounding div.
      class InlineSubmit
        extend MethodBuilder

        build_methods_for :csrf

        def initialize(view_only, submit_caption, disable_caption, submit_id, hidden_submit, remote) # rubocop:disable Metrics/ParameterLists
          @view_only = view_only
          @submit_caption = submit_caption
          @disable_caption = disable_caption
          @submit_id = submit_id
          @hidden_submit = hidden_submit
          @remote = remote
        end

        # Is this node invisible?
        #
        # @return [boolean] - true if it should not be rendered at all, else false.
        def invisible?
          false
        end

        # Is this node hidden?
        #
        # @return [boolean] - true if it should be rendered as hidden, else false.
        def hidden?
          false
        end

        # Render this node as HTML link.
        #
        # @return [string] - HTML representation of this node.
        def render
          remote_inject = @remote ? '-briefly' : ''
          id_str = @submit_id.nil? ? '' : %( id="#{@submit_id}")
          hidden_str = @hidden_submit ? ' hidden' : ''
          if @view_only
            %(<input type="submit" name="commit"#{id_str} value="Close" class="close-dialog white bg-blue br2 dim pa3 ba b--near-white"#{hidden_str}>)
          else
            %(<input type="submit" name="commit"#{id_str} value="#{@submit_caption}" data#{remote_inject}-disable-with="#{@disable_caption}" class="white bg-green br2 dim pa3 ba b--near-white"#{hidden_str}>)
          end
        end
      end
    end
  end
end
