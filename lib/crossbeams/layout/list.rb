# frozen_string_literal: true

module Crossbeams
  module Layout
    # A list of items.
    class List
      # include PageNode
      attr_reader :items

      def initialize(page_config, items, options = {})
        @page_config = page_config
        @items       = Array(items)
        @items       = @items.map(&:first) if @items.first.is_a?(Array) && options[:remove_item_url].nil?
        @options     = options
        validate_remove_item_url(options)
      end

      # Is this node invisible?
      #
      # @return [boolean] - true if it should not be rendered at all, else false.
      def invisible?
        false
      end

      def add_csrf_tag(tag)
        # noop
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
        #{caption}<ol id="#{dom_id}"#{classes}#{remove_url}>
        #{item_renders}
        </ol>
        HTML
      end

      private

      def remove_url
        return '' if @remove_item_url.nil?

        %(data-remove-item-url="#{@remove_item_url}")
      end

      def validate_remove_item_url(options)
        @remove_item_url = options[:remove_item_url]
        return if @remove_item_url.nil?

        raise ArgumentError, %(List "remove_item_url" must include "$:id$" token) unless @remove_item_url.include?('$:id$')

        raise ArgumentError, %(List items must be 2-D array if "remove_item_url" is provided) unless @items.empty? || @items.first.is_a?(Array)
      end

      def validate_scroll_height
        return if @options[:scroll_height].nil?

        raise ArgumentError, 'List: scroll_height can only be ":short" or ":medium"' unless %i[short medium].include?(@options[:scroll_height])
      end

      def classes
        return '' unless @options[:scroll_height] || @options[:filled_background]

        validate_scroll_height
        ar = []
        ar << ' bg-light-gray ba b--silver br2 pt1 pb1' if @options[:filled_background]
        ar << " cbl-list-scroll-#{@options[:scroll_height]}" if @options[:scroll_height]
        %(class="#{ar.join}")
      end

      def dom_id
        @options[:dom_id] || "cbl-list-#{Time.now.to_i}"
      end

      def caption
        return '' if @options[:caption].nil?

        <<~HTML
          <label>#{@options[:caption]}</label>
        HTML
      end

      def item_renders
        return '' if @items.nil_or_empty?

        if @remove_item_url.nil?
          plain_item_renders
        else
          remove_item_renders
        end
      end

      def plain_item_renders
        items = @items.first.is_a?(Array) ? @items.map(&:first) : @items
        items.map do |text|
          %(<li>#{text}</li>)
        end.join("\n")
      end

      def remove_item_renders
        @items.map do |text, id|
          %(<li data-item-id="#{id}">#{minus_icon(id)} #{text}</li>)
        end.join("\n")
      end

      def minus_icon(id)
        Icon.new(:minus, css_class: 'red pointer', attrs: [%(data-remove-item="#{id}")]).render
      end
    end
  end
end
