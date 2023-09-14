# frozen_string_literal: true

module Crossbeams
  module Layout
    # A link renderer - for rendering a link outside a form.
    class Link
      include PageNode
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
          hidden_string,
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
        return unless @window || @icon

        raise ArgumentError, 'Crossbeams::Layout::Link you cannot have a loading window that is also remote, newtab or a popup' if @window && %i[popup replace_dialog newtab remote].include?(@behaviour)
        raise ArgumentError, "Crossbeams::Layout::Link - icon #{@icon} is not a valid choice" unless @icon.nil? || Icon::ICONS.keys.include?(@icon)
        raise ArgumentError, 'Crossbeams::Layout::Link icon is not applicable for back button or loading window' if @icon && (style == :back_button || @window)
      end

      def class_strings # rubocop:disable Metrics/AbcSize
        if style == :button
          col = button_colour
          %(class="f#{button_font_size} link dim br2 ph3 pv2 dib white bg-#{col}#{user_class}")
        elsif style == :small_button
          %(class="link dim br1 ph2 dib white bg-silver#{user_class}")
        elsif style == :back_button
          %(class="f#{button_font_size} link dim br2 ph3 pv2 dib white bg-dark-blue#{user_class}")
        elsif style == :action_button
          %(class="f#{button_font_size} link dim br2 ph3 pv2 dib white bg-green#{user_class}")
        else
          css_class.empty? ? '' : %(class="#{css_class}")
        end
      end

      def button_colour
        case @colour
        when nil, :standard
          'silver'
        when :green
          'dark-green'
        when :amber
          'gold'
        when :red
          'dark-red'
        when :blue
          'dark-blue'
        else
          raise ArgumentError, "Invalid button colour - #{@colour}"
        end
      end

      def user_class
        css_class.empty? ? '' : " #{css_class}"
      end

      def hidden_string
        return '' if visible

        'hidden'
      end

      def render_text
        if style == :back_button
          "#{Icon.new(:back).render} #{text}"
        elsif @icon
          "#{Icon.new(@icon).render} #{text}"
        elsif @window
          "#{Icon.new(:newwindow).render} #{text}"
        elsif @behaviour == :newtab
          "#{Icon.new(:newtab).render} #{text}"
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
        return '6' if text_size == '1'

        (7 - text_size.to_i).to_s
      end
    end
  end
end
