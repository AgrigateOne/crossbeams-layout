# frozen_string_literal: true

module Crossbeams
  module Layout
    # A help link renderer - for rendering a button to open a help page.
    class HelpLink
      extend MethodBuilder

      node_adders :csrf
      attr_reader :text, :help_type, :path, :dialog

      def initialize(options)
        @text      = options.fetch(:text, 'Help')
        @help_type = options.fetch(:help_type, 'app')
        @path      = options.fetch(:path)
        @lift      = options.fetch(:lift, 0) * -1
        @dialog    = options.fetch(:for_dialog, false)
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

      # Render this node as HTML help link.
      #
      # @return [string] - HTML representation of this node.
      def render
        <<-HTML
          <div class="relative">
            <a href="#{url}"class="#{position_classes}f6 link dim br2 ph3 pv2 dib white bg-blue" data-help-link="Y" target="cbf-help">#{Icon.new(:question).render} #{text}</a>
          </div>
        HTML
      end

      private

      def url
        ar = [help_type]
        path.each { |p| ar << p.to_s }
        "/help/#{ar.join('/')}"
      end

      def position_classes
        return '' if dialog

        "absolute top-#{@lift} right-0 "
      end
    end
  end
end
