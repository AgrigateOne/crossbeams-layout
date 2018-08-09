# frozen_string_literal: true

module Crossbeams
  module Layout
    # A link renderer - for rendering a link outside a form.
    class Link
      include PageNode
      attr_reader :text, :url, :style, :behaviour

      def initialize(options)
        @text      = options[:text]
        @url       = options[:url]
        raise ArgumentError, 'Crossbeams::Layout::Link requires text and url options' if @text.nil? || @url.nil?
        @style     = options[:style] || :link
        @behaviour = options[:behaviour] || :direct # popup window, popup dialog, modal...
        @nodes     = []
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
        <a href="#{url}"#{class_strings}#{behaviour_string}>#{render_text}</a>
        HTML
      end

      private

      def class_strings
        if style == :button
          %( class="f6 link dim br2 ph3 pv2 dib white bg-silver")
        elsif style == :back_button
          %( class="f6 link dim br2 ph3 pv2 dib white bg-dark-blue")
        else
          ''
        end
      end

      def render_text
        if style == :back_button
          %(<svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><polygon points="3.828 9 9.899 2.929 8.485 1.515 0 10 .707 10.707 8.485 18.485 9.899 17.071 3.828 11 20 11 20 9 3.828 9"/></svg> #{text})
        else
          text
        end
      end

      def behaviour_string
        if @behaviour == :popup
          ' data-popup-dialog="true"'
        else
          ''
        end
      end
    end
  end
end
