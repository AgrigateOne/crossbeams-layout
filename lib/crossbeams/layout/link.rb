# frozen_string_literal: true

module Crossbeams
  module Layout
    # A link renderer - for rendering a link outside a form.
    class Link
      include PageNode
      attr_reader :text, :url, :style, :behaviour

      def initialize(options) #text, url, style = nil, behaviour = nil)
        @text      = options[:text]
        @url       = options[:url]
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
        <<-EOS
        <a href="#{url}" #{class_strings}>#{text}</a>
        EOS
      end

      private

      def class_strings
        if style == :button
          %Q{class="f6 link dim br2 ph3 pv2 mb2 dib white bg-silver"}
        else
          ''
        end
      end
    end
  end
end
