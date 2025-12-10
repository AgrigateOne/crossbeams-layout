# frozen_string_literal: true

module Crossbeams
  module Layout
    # A collection of elements arranged in a flowing grid
    class Collection
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf

      ListNode = Struct.new(:item, :colour) do
        def render
          # TODO: Allow individual override of colour?
          %(<div class="p-2 text-center bg-yellow-100 min-w-20">#{item}</div>)
        end
      end

      def initialize
        @nodes = []
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

      # Add a control (button, link) to the collection.
      #
      # @param page_control_definition [hash] the page control attributes
      # @return [void]
      def add_control(page_control_definition)
        raise ArgumentError, 'Collection: "add_control" did not provide a "control_type"' unless page_control_definition[:control_type]
        raise ArgumentError, 'Collection: "add_control" can only accept a :link control type"' unless page_control_definition[:control_type] == :link

        @nodes << Link.new(page_control_definition.merge(style: :collection_button))
      end

      # Add a list of text nodes to the collection.
      #
      # @param list [array] the list of strings to display
      # @return [void]
      def add_list(list)
        list.each { |l| @nodes << ListNode.new(l) }
      end

      def dom_id(val)
        @dom_id = val
      end

      # Render this node as HTML div containg a collection of buttons or divs
      #
      # @return [string] - HTML representation of this node.
      def render
        <<-HTML
          <div #{dom_id_render}class="flex flex-wrap flex-grow gap-4">
            #{render_items}
          </div>
        HTML
      end

      # Render just the inner HTML of this control.
      # (For use when replacing a DOM element's inner content)
      #
      # @return [string] - HTML representation of the inner nodes.
      def render_inner
        render_items
      end

      private

      def dom_id_render
        return '' unless @dom_id

        %(id="#{@dom_id}" )
      end

      def render_items
        @nodes.map(&:render).join("\n")
      end
    end
  end
end
