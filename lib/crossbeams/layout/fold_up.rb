# frozen_string_literal: true

module Crossbeams
  module Layout
    # A FoldUp wraps its content in a <display> element which is folded up by default.
    class FoldUp
      extend MethodBuilder

      node_adders :address,
                  :contact_method,
                  :csrf,
                  :diff,
                  :grid,
                  :notice,
                  :row,
                  :section,
                  :table,
                  :text

      attr_reader :sequence, :nodes, :page_config, :caption_text

      def initialize(page_config, sequence)
        @caption_text = 'Details'
        @open         = false
        @sequence     = sequence
        @nodes        = []
        @page_config  = page_config
      end

      def caption(value)
        @caption_text = value
      end

      def open!
        @open = true
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form
        @nodes << form
      end

      def add_field(name, options = {})
        @nodes << Field.new(page_config, name, options)
      end

      def render
        return '' if invisible?

        row_renders = nodes.reject(&:invisible?).map(&:render).join("\n")
        <<~HTML
          <details class="pv2"#{open_state}>
            <summary class="pointer b blue shadow-3 pa1 mr2">#{caption_text}</summary>
            #{row_renders}
          </details>
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

      private

      def open_state
        @open ? ' open' : ''
      end
    end
  end
end
