# frozen_string_literal: true

module Crossbeams
  module Layout
    # A link renderer - for rendering a link outside a form.
    class Link
      include PageNode
      attr_reader :text, :url, :style, :behaviour, :css_class, :id, :visible

      def initialize(options) # rubocop:disable Metrics/AbcSize
        @text      = options.fetch(:text)
        @url       = options.fetch(:url)
        @style     = options[:style] || :link
        @icon      = options[:icon]
        @behaviour = options[:behaviour] || :direct # popup window, popup dialog, modal...
        @css_class = options[:css_class] || ''
        @grid_id   = options[:grid_id] || ''
        @prompt    = options[:prompt]
        @id        = options[:id]
        @visible   = options.fetch(:visible, true)
        @window    = options[:loading_window]
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
          loading_window_string
        ].join(' ').squeeze(' ').rstrip
      end

      def render_id
        return '' unless id

        %(id="#{id}" )
      end

      def assert_options_ok!
        return unless @window || @icon
        raise ArgumentError, 'Crossbeams::Layout::Link you cannot have a loading window that is also a popup' if %i[popup replace_dialog].include?(@behaviour)
        raise ArgumentError, "Crossbeams::Layout::Link - icon #{@icon} is not a valid choice" unless @icon.nil? || Icon::ICONS.keys.include?(@icon)
        raise ArgumentError, 'Crossbeams::Layout::Link icon is not applicable for back button or loading window' if @icon && (style == :back_button || @window)
      end

      def class_strings
        if style == :button
          %(class="f6 link dim br2 ph3 pv2 dib white bg-silver#{user_class}")
        elsif style == :small_button
          %(class="link dim br1 ph2 dib white bg-silver#{user_class}")
        elsif style == :back_button
          %(class="f6 link dim br2 ph3 pv2 dib white bg-dark-blue#{user_class}")
        elsif style == :action_button
          %(class="f6 link dim br2 ph3 pv2 dib white bg-green#{user_class}")
        else
          css_class.empty? ? '' : %(class="#{css_class}")
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
        else
          text
        end
      end

      def behaviour_string
        if @behaviour == :popup
          'data-popup-dialog="true"'
        elsif @behaviour == :replace_dialog
          'data-replace-dialog="true"'
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
    end
  end
end
