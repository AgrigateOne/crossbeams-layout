# frozen_string_literal: true

module Crossbeams
  module Layout
    # Form object.
    class Form # rubocop:disable Metrics/ClassLength
      attr_reader :sequence, :nodes, :page_config, :form_action, :form_method,
                  :got_row, :no_row, :csrf_tag, :remote_form, :form_config,
                  :multipart_form

      def initialize(page_config, section_sequence, sequence)
        @section_sequence = section_sequence
        @sequence         = sequence
        @form_action      = '/' # work out from page_config.object?
        @nodes            = []
        @page_config      = page_config
        @form_config      = PageConfig.new({}) # OpenStruct.new
        @form_method      = :create
        @remote_form      = false
        @multipart_form   = false
        @view_only        = false
        @inline           = false
        @got_row          = false
        @no_row           = false
        @csrf_tag         = nil
        @submit_caption   = 'Submit'
        @disable_caption  = 'Submitting'
      end

      def form_config=(value)
        @form_config      = PageConfig.new(value) # OpenStruct.new
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

      # Make this a view-only form.
      # @returns [void]
      def view_only!
        @view_only = true
      end

      # Include the submit button on the same line as input.
      # @returns [void]
      def inline!
        @inline = true
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
      end
      # --- ...FROM PAGE FOR OVERRIDE

      def method(method)
        raise ArgumentError, "Invalid form method \"#{method}\"" unless %i[create update].include?(method)
        @form_method = method
      end

      def row
        @got_row = true
        raise 'Cannot mix row and non-row text or fields' if no_row
        row = Row.new(config_for_field, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      def add_field(name, options = {})
        @no_row = true
        raise 'Cannot mix row and fields' if got_row
        @nodes << Field.new(config_for_field, name, options)
      end

      def config_for_field
        # @form_config.to_h.empty? ? @page_config : @form_config
        @form_config.form_object.nil? ? @page_config : @form_config
        # @form_config.to_h.empty? ? @page_config : PageConfig.new(@form_config)
      end

      def add_text(text, opts = {})
        @no_row = true
        raise 'Cannot mix row and text' if got_row
        @nodes << Text.new(page_config, text, opts)
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

      def form_method_str
        case form_method
        when :create
          ''
        when :update
          '<input type="hidden" name="_method" value="PATCH">'
        end
      end

      def submit_captions(value, disabled_value = nil)
        @submit_caption = value
        @disable_caption = disabled_value || value
      end

      def render
        renders = sub_renders
        remote_str = remote_form ? ' data-remote="true"' : ''
        multipart_str = multipart_form ? ' enctype="multipart/form-data"' : ''
        submit_markup = if @inline
                          ''
                        else
                          <<~HTML
                            <div class="crossbeams-actions">
                              #{submit_button}
                            </div>
                          HTML
                        end
        # TODO: fix form id...
        <<~HTML
          <form class="crossbeams-form" id="edit_user_1" action="#{form_action}"#{multipart_str}#{remote_str} accept-charset="utf-8" method="POST">
            #{csrf_tag}
            #{form_method_str}
            #{renders}
            #{submit_markup}
          </form>
        HTML
      end

      private

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
        row.render + "\n"
      end

      def submit_button
        disabler = @remote_form ? 'briefly-disable' : 'disable'
        if @view_only
          %(<input type="submit" name="commit" value="Close" class="close-dialog white bg-green br2 dim pa3 ba b--near-white">)
        else
          %(<input type="submit" name="commit" value="#{@submit_caption}" data-#{disabler}-with="#{@disable_caption}" class="white bg-green br2 dim pa3 ba b--near-white">)
        end
      end

      def inline_submit
        sub = InlineSubmit.new(@view_only, @submit_caption, @disable_caption)
        sub
      end

      class InlineSubmit
        include PageNode

        def initialize(view_only, submit_caption, disable_caption)
          @view_only = view_only
          @submit_caption = submit_caption
          @disable_caption = disable_caption
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
          if @view_only
            %(<input type="submit" name="commit" value="Close" class="close-dialog white bg-green br2 dim pa3 ba b--near-white">)
          else
            %(<input type="submit" name="commit" value="#{@submit_caption}" data-disable-with="#{@disable_caption}" class="white bg-green br2 dim pa3 ba b--near-white">)
          end
        end
      end
    end
  end
end
