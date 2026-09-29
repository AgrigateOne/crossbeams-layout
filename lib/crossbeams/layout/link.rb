# frozen_string_literal: true

module Crossbeams
  module Layout
    # A link renderer - for rendering a link outside a form.
    class Link # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :text, :url, :style, :behaviour, :css_class, :id, :visible, :text_size

      def initialize(options) # rubocop:disable Metrics/AbcSize
        @text      = options.fetch(:text)
        @url       = options.fetch(:url)
        @style     = options[:style] || :link
        @colour    = options[:button_colour]
        @icon      = options[:icon]
        @behaviour = options[:behaviour] || :direct # popup window, popup dialog, modal...
        @css_class = options[:css_class] || ''
        @grid_id   = options[:grid_id] || ''
        @prompt    = options[:prompt]
        @id        = options[:id]
        @visible   = options.fetch(:visible, true)
        @inline    = options.fetch(:inline, false)
        @window    = options[:loading_window]
        @title     = options[:title]
        @text_size = options[:text_size] || '1'
        @nodes     = []
        assert_options_ok!
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
        <<-HTML
          <a #{render_id}href="#{url}"#{attrs}>#{render_text}</a>
        HTML
      end

      private

      def attrs
        [
          ' ',
          class_strings,
          # hidden_string,
          behaviour_string,
          grid_string,
          prompt_string,
          loading_window_string,
          new_page_string,
          title_string
        ].join(' ').squeeze(' ').rstrip
      end

      def render_id
        return '' unless id

        %(id="#{id}" )
      end

      def assert_options_ok! # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        raise ArgumentError, "Crossbeams::Layout::Link Invalid text size #{@text_size}" unless %w[1 2 3 4 5 6].include?(@text_size.to_s)
        raise ArgumentError, 'Crossbeams::Layout::Link Only provide button colour for a `button` style' if @colour && @style != :button
        raise ArgumentError, "Crossbeams::Layout::Link Invalid button colour option - #{@colour}" if @colour && !%i[standard red green amber blue].include?(@colour)
        raise ArgumentError, "Crossbeams::Layout::Link - behaviour #{@behaviour} is not a valid choice" unless %i[direct popup remote replace_dialog newtab].include?(@behaviour)
        return unless @window || @icon

        raise ArgumentError, 'Crossbeams::Layout::Link you cannot have a loading window that is also remote, newtab or a popup' if @window && %i[popup replace_dialog newtab remote].include?(@behaviour)
        raise ArgumentError, "Crossbeams::Layout::Link - icon #{@icon} is not a valid choice" unless @icon.nil? || Icon::ICONS.keys.include?(@icon)
        raise ArgumentError, 'Crossbeams::Layout::Link icon is not applicable for back button or loading window' if @icon && (style == :back_button || @window)
      end

      def class_strings # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        case style
        when :button
          to_colour = "bg-#{button_colour}-500"
          from_colour = "bg-#{SC.css_class(:secondary_bg)}"
          to_colour = "bg-#{SC.css_class(:secondary_bg)}" if button_colour.nil?
          %(class="#{button_font_size} #{btn_secondary.gsub(from_colour, to_colour)} max-w-fit #{user_class}")
        when :small_button
          warn 'Crossbeams::Layout::Link - style `small_button` has been deprecated. Use an icon button instead.'
          %(class="#{SC.css_class(:link)}#{inline_or_hidden}")
        when :back_button
          %(class="#{btn_primary} max-w-fit#{user_class}")
        when :info_button
          %(class="#{button_font_size} #{btn_info} max-w-fit #{user_class}")
        when :success_button
          %(class="#{button_font_size} #{btn_success} max-w-fit #{user_class}")
        when :warning_button
          %(class="#{button_font_size} #{btn_warning} max-w-fit #{user_class}")
        when :error_button
          %(class="#{button_font_size} #{btn_error} max-w-fit #{user_class}")
        when :action_button
          %(class="#{button_font_size} #{btn_primary} max-w-fit #{user_class}")
        when :collection_button
          %(class="#{btn_collection} #{user_class}")
        else
          css_class.empty? ? %(class="#{SC.css_class(:link)}#{inline_or_hidden}") : %(class="#{SC.css_class(:link)}#{css_class}#{inline_or_hidden}")
        end
      end

      def btn_primary
        tweak_display(SC.css_class(:button_primary))
      end

      def btn_secondary
        tweak_display(SC.css_class(:button_secondary))
      end

      def btn_success
        tweak_display(SC.css_class(:button_success))
      end

      def btn_warning
        tweak_display(SC.css_class(:button_warning))
      end

      def btn_error
        tweak_display(SC.css_class(:button_error))
      end

      def btn_info
        tweak_display(SC.css_class(:button_info))
      end

      def btn_collection
        tweak_display(SC.css_class(:button_for_collection))
      end

      def tweak_display(css)
        return css.sub('flex', 'hidden') unless @visible
        return css.sub('flex', 'inline-block') if @inline

        css
      end

      def button_colour
        case @colour
        when nil, :standard
          nil
        when :green
          'green'
        when :amber
          'yellow'
        when :red
          'red'
        when :blue
          'blue'
        else
          raise ArgumentError, "Invalid button colour - #{@colour}"
        end
      end

      def user_class
        # css_class.empty? ? inline_class : " #{css_class}#{inline_class}"
        css_class
      end

      def hidden_string
        return '' if visible

        'hidden'
      end

      def inline_class
        return '' unless @inline

        ' inline-block'
      end

      def inline_or_hidden
        return ' hidden' unless @visible
        return ' inline-block' if @inline

        ''
      end

      def render_text
        if style == :back_button
          "#{Icon.new(:back, css_class: 'align-middle inline-block').render} #{text}"
        elsif @icon
          "#{Icon.new(@icon, css_class: 'align-middle inline-block').render} #{text}"
        elsif @window
          "#{Icon.new(:newwindow, css_class: 'align-middle inline-block').render} #{text}"
        elsif @behaviour == :newtab
          "#{Icon.new(:newtab, css_class: 'align-middle inline-block').render} #{text}"
        else
          text
        end
      end

      def behaviour_string
        case @behaviour
        when :popup
          'data-popup-dialog="true"'
        when :replace_dialog
          'data-replace-dialog="true"'
        when :remote
          'data-remote-link="true"'
        when :newtab
          'target="_blank"'
        else
          ''
        end
      end

      def grid_string
        @grid_id == '' ? '' : %(data-grid-id="#{@grid_id}")
      end

      def prompt_string
        return '' if @prompt.nil? || @prompt == false

        if @prompt == true || @prompt.casecmp('Y').zero?
          'data-prompt="Are you sure?"'
        else
          "data-prompt=\"#{@prompt}\""
        end
      end

      def loading_window_string
        return '' if @window.nil? || @window == false

        'data-loading-window="true" title="opens in a new window"'
      end

      # Identify a link to a new page so that it can be disabled once clicked.
      def new_page_string
        return '' unless @behaviour == :direct
        return '' if @window || @prompt

        'data-new-page-link="true"'
      end

      def title_string
        return 'title="Opens in a new tab"' if @behaviour == :newtab
        return '' if @window || @title.nil?

        %(title="#{@title}")
      end

      def button_font_size
        %w[text-base text-lg text-xl text-2xl text-3xl text-4xl][text_size.to_i - 1]
        # return '6' if text_size == '1'

        # (7 - text_size.to_i).to_s
      end
    end
  end
end
