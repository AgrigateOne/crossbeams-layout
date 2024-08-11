# frozen_string_literal: true

module Crossbeams
  module Layout
    # A button renderer with dropdown options - for rendering a button with a set of links to click.
    class DropdownButton # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      node_adders :csrf
      attr_reader :text, :style, :css_class, :id, :visible, :items

      def initialize(options)
        @text      = options.fetch(:text)
        @style     = options[:style] || :button
        @icon      = options[:icon]
        @css_class = options[:css_class] || ''
        @id        = options[:id]
        @visible   = options.fetch(:visible, true)
        @items     = options[:items] || []
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
          <div #{render_id}class="crossbeams-dropdown-button bn br2 bg-silver"#{hidden_string}>
            <button type="button"#{attrs}>
              #{render_text}
            </button>
            <div class="crossbeams-dropdown-content">
              #{dropdown_items}
            </div>
          </div>
        HTML
      end

      private

      def dropdown_items
        items.map do |item|
          # Include icons for direct, popup, replace, loading at the start of the text...
          icon = if item[:loading_window]
                   Icon.new(:newwindow).render
                 elsif %i[popup replace_dialog].include?(item[:behaviour])
                   Icon.new(:window).render
                 else
                   Icon.new(:link).render
                 end
          %(<a data-button-dropdown="Y" href="#{item[:url]}" class="db pa2 dim nowrap"#{item_attrs(item)}>#{icon} #{item[:text]}</a>)
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
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton you cannot have a loading window that is also a popup' if item[:loading_window] && %i[popup replace_dialog].include?(item[:behaviour])
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton - back button items must use direct links, not a loading window' if style == :back_button && item[:loading_window]
          raise ArgumentError, 'Crossbeams::Layout::DropdownButton - back button items must use direct links, not a dialog' if style == :back_button && %i[popup replace_dialog].include?(item[:behaviour])
        end
      end

      def class_strings
        case style
        when :button
          %(class="pointer f6 bn dim br2 ph3 pv2 dib white bg-silver#{user_class}")
        when :small_button
          %(class="pointer bn dim br1 ph2 dib white bg-silver#{user_class}")
        when :back_button
          %(class="pointer f6 bn dim br2 ph3 pv2 dib white bg-dark-blue#{user_class}")
        when :action_button
          %(class="pointer f6 bn dim br2 ph3 pv2 dib white bg-green#{user_class}")
        else
          raise ArgumentError, "Crossbeams::Layout::DropdownButton - invalid style option: #{style}"
        end
      end

      def user_class
        css_class.empty? ? '' : " #{css_class}"
      end

      def hidden_string
        return '' if visible

        ' hidden'
      end

      def hidden_item_string(item)
        return '' unless item.key?(:visible)
        return '' if item[:visible]

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

      def behaviour_string(item)
        return '' unless item[:behaviour]

        case item[:behaviour]
        when :popup
          'data-popup-dialog="true"'
        when :replace_dialog
          'data-replace-dialog="true"'
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
__END__
Hover - show list
Click item, amend URL (before popup/loading is fired in JS)
How to reset it, though...
URL has $:$ part - replaced by value of item, button has default
Click button, place default in URL
Click item, place value in URL & examine data- to see if popup/loading.

  Might want a button that does nothing and only the hovers do something...
  And a button that employs a default with dropdowns as alternates...

  JS:
  1. popup & loading & plain click(!) - does button have default param & if so, use it
2. item click - place value in url & check if we need to click, popup or load...

  data-dropdown-button-value=""
item checks if linked to button with data-dropdown-value to decide if url must be changed... (else whole URL on item)

<a
href="/finished_goods/reports/addendum/516"
class="f6 link dim br2 ph3 pv2 dib white bg-silver"
data-loading-window="true"
title="opens in a new window">
<svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9 10V8h2v2h2v2h-2v2H9v-2H7v-2h2zM0 3c0-1.1.9-2 2-2h16a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3zm2 2v12h16V5H2z"></path></svg>
Addendum
</a>
