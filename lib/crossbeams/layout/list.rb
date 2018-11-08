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
        @items       = @items.map(&:first) if @items.first.is_a?(Array)
        @options     = options
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
        #{caption}<ol id="#{dom_id}">
        #{item_renders}
        </ol>
        HTML
      end

      private

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
        @items.map do |text|
          %(<li>#{text}</li>)
        end.join("\n")
      end
    end
  end
end
