# frozen_string_literal: true

module Crossbeams
  module Layout
    # A button renderer with dropdown options - for rendering a button with a set of links to click.
    class DropdownButton # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :text, :style, :css_class, :id, :visible, :items

      def initialize(options)
        @text      = options.fetch(:text)
        @style     = options[:style] || :button
        @icon      = options[:icon]
        @css_class = options[:css_class] || ''
        @id        = options[:id]
        @visible   = options.fetch(:visible, true)
        @inline    = options.fetch(:inline, false)
        @items     = (Array(options[:items]) || []).compact
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

      # Render this node as HTML button with dropdown items.
      #
      # @return [string] - HTML representation of this node.
      def render
        <<-HTML
          <div #{render_id}class="crossbeams-dropdown-button w-fit relative#{inline_class}"#{hidden_string}>
            <button type="button"#{attrs}>
              #{render_text}
            </button>
            <div class="crossbeams-dropdown-content min-w-full flex hidden absolute border border-slate-200 right-0 top-11 z-10 bg-white">
              #{dropdown_items}
            </div>
          </div>
        HTML
      end

      private

      def inline_class
        return '' unless @inline

        ' inline-block'
      end

      def dropdown_items # rubocop:disable Metrics/AbcSize
        Array(items).map do |item|
          # Include icons for direct, popup, replace, loading at the start of the text...
          icon = if item[:loading_window]
                   Icon.new(:newwindow).render
                 elsif %i[popup replace_dialog remote].include?(item[:behaviour])
                   Icon.new(:window).render
                 else
                   Icon.new(:link).render
                 end
          %(<a data-button-dropdown="Y" href="#{item[:url]}" class="flex items-center gap-3 block w-min-fit w-full grow py-2 px-3 rounded cursor-pointer outline-none whitespace-nowrap select-none #{SC.css_class(:link)} hover:bg-slate-200"#{item_attrs(item)}>#{icon} #{item[:text]}</a>)
        end.join("\n")
      end

      def item_attrs(item)
        [
          ' ',
          item_id(item),
          hidden_item_string(item),
          behaviour_string(item),
          grid_string(item),
          prompt_string(item),
          loading_window_string(item)
        ].join(' ').squeeze(' ').rstrip
      end

      def attrs
        [
          ' ',
          class_strings
        ].join(' ').squeeze(' ').rstrip
      end

      def item_id(item)
        return '' unless item[:id]

        %(id="#{item[:id]}" )
      end

      def render_id
        return '' unless id

        %(id="#{id}" )
      end

      def assert_options_ok! # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if @icon
          raise ArgumentError, "Crossbeams::Layout::DropdownButton - icon #{@icon} is not a valid choice" unless @icon.nil? || Icon::ICONS.keys.include?(@icon)
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton icon is not applicable for back button' if @icon && style == :back_button
        end
        raise ArgumentError, 'Crossbeams::Layout::DropdownButton - no items specified' if items.empty?

        items.each do |item|
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton - items must have URL and TEXT attributes' unless item[:url] && item[:text]
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton you cannot have a loading window that is also a popup' if item[:loading_window] && %i[popup replace_dialog remote].include?(item[:behaviour])
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton - back button items must use direct links, not a loading window' if style == :back_button && item[:loading_window]
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton - back button items must use direct links, not a dialog' if style == :back_button && %i[popup replace_dialog].include?(item[:behaviour])
        end
      end

      def class_strings
        case style
        when :button
          %(class="inline-block #{SC.css_class(:button_secondary)}#{user_class}")
        when :small_button
          %(class="font-medium select-none whitespace-nowrap rounded border-2 cursor-pointer outline-none focus-visible:ring focus-visible:ring-offset-white focus-visible:ring-offset-2 px-1.5 h-[2.25rem] min-w-[2.25rem] bg-ocean-500 text-white border-ocean-500 active:bg-ocean-700 active:border-ocean-700 hover:bg-ocean-700 hover:border-ocean-700 disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-400 disabled:border-slate-200 disabled:hover:bg-slate-200 disabled:hover:border-slate-200 focus-visible:ring-ocean-500)
        when :back_button
          %(class="inline-block #{SC.css_class(:button_primary)}#{user_class}")
        when :action_button
          %(class="inline-block #{SC.css_class(:button_primary)}#{user_class}")
        else
          raise ArgumentError, "Crossbeams::Layout::DropdownButton - invalid style option: #{style}"
        end
      end

      def user_class
        css_class.empty? ? '' : " #{css_class}"
      end

      def hidden_string
        return '' if visible && !Array(items).empty?

        ' hidden'
      end

      def hidden_item_string(item)
        return '' unless item.key?(:visible)
        return '' if item[:visible]

        'hidden'
      end

      def render_text # rubocop:disable Metrics/AbcSize
        if style == :back_button
          "#{Icon.new(:back, css_class: 'align-middle inline-block').render} #{text} #{Icon.new(:dropdown, css_class: ['ml-2 inline-block']).render}"
        elsif @icon
          "#{Icon.new(@icon, css_class: 'align-middle inline-block').render} #{text} #{Icon.new(:dropdown, css_class: ['ml-2 inline-block']).render}"
        elsif @window
          "#{Icon.new(:newwindow, css_class: 'align-middle inline-block').render} #{text} #{Icon.new(:dropdown, css_class: ['ml-2 inline-block']).render}"
        else
          "#{text} #{Icon.new(:dropdown, css_class: ['ml-2 inline-block']).render}"
        end
      end

      def behaviour_string(item)
        return '' unless item[:behaviour]

        case item[:behaviour]
        when :popup
          'data-popup-dialog="true"'
        when :replace_dialog
          'data-replace-dialog="true"'
        when :remote
          'data-remote-link="true"'
        else
          ''
        end
      end

      def grid_string(item)
        return '' unless item[:grid_id]

        %(data-grid-id="#{item[:grid_id]}")
      end

      def prompt_string(item)
        return '' if item[:prompt].nil? || item[:prompt] == false

        if item[:prompt] == true || item[:prompt].casecmp('Y').zero?
          'data-prompt="Are you sure?"'
        else
          "data-prompt=\"#{item[:prompt]}\""
        end
      end

      def loading_window_string(item)
        return '' if item[:loading_window].nil? || item[:loading_window] == false

        'data-loading-window="true" title="opens in a new window"'
      end
    end
  end
end
