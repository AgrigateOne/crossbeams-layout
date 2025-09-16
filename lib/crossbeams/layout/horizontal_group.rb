# frozen_string_literal: true

module Crossbeams
  module Layout
    # A HorizontalGroup groups its nodes in a horizontal flexbox
    class HorizontalGroup
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :address,
                        :contact_method,
                        :csrf,
                        :table,
                        :text

      attr_reader :sequence, :nodes, :page_config, :caption_text

      def initialize(page_config, sequence)
        @sequence = sequence
        @nodes = []
        @page_config = page_config
        @align = :right
      end

      # Change the alignment of the group's content to align to the left
      #
      # @return [void]
      def align_left!
        @align = :left
      end

      # Add a control (button, link) to the group.
      #
      # @return [void]
      def add_control(page_control_definition)
        raise ArgumentError, 'HorizontalGroup: "add_control" did not provide a "control_type"' unless page_control_definition[:control_type]

        @nodes << Link.new(page_control_definition.merge(inline: true)) if page_control_definition[:control_type] == :link
        @nodes << DropdownButton.new(page_control_definition.merge(inline: true)) if page_control_definition[:control_type] == :dropdown_button
        @nodes << HelpLink.new(page_control_definition) if page_control_definition[:control_type] == :help_link
      end

      def add_help_link(options)
        @nodes << HelpLink.new(options)
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def render
        return '' if invisible?

        row_renders = nodes.reject(&:invisible?).map(&:render).join("\n")
        just = @align == :right ? 'justify-end' : 'justify-start'
        <<~HTML
          <div class="flex flex-row gap-4 #{just} flex-wrap">
            #{row_renders}
          </div>
        HTML
      end

      # Are there any Javascript snippets to be included in the page's DOMContentLoaded event?
      def dom_loaded?
        has_js = false
        nodes.reject(&:invisible?).each do |node|
          has_js = true if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        has_js
      end

      # DOM loaded javascript snippets.
      def list_dom_loaded
        ar = []
        nodes.reject(&:invisible?).each do |node|
          ar += node.list_dom_loaded if node.respond_to?(:dom_loaded?) && node.dom_loaded?
        end
        ar
      end
    end
  end
end

