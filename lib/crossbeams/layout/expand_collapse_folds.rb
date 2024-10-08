# frozen_string_literal: true

module Crossbeams
  module Layout
    # Expand-all and collapse-all control for opening/closing all FoldUps in a form.
    class ExpandCollapseFolds
      extend MethodBuilder

      build_methods_for :csrf
      attr_reader :sequence, :nodes, :page_config, :parent_dom_id

      def initialize(page_config, sequence, options = {})
        @options = options
        @parent_dom_id = options[:parent_dom_id] || 'form'
        @sequence = sequence
        @nodes = []
        @page_config = page_config
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        return '' if invisible?

        <<~HTML
          <a href="/" class="#{css_class.join(' ')}" #{title(true)}data-expand-collapse="open" data-expand-collapse-dom="#{parent_dom_id}">#{expand_text}</a>
          <a href="/" class="ml2 #{css_class.join(' ')}" #{title(false)}data-expand-collapse="close" data-expand-collapse-dom="#{parent_dom_id}">#{collapse_text}</a>
        HTML
      end

      private

      def expand_text
        @options[:mini] ? Icon.new(:plus).render : "#{Icon.new(:plus).render} Expand all"
      end

      def collapse_text
        @options[:mini] ? Icon.new(:minus).render : "#{Icon.new(:minus).render} Collapse all"
      end

      def title(open)
        return '' unless @options[:mini]

        if open
          'title="Expand all"'
        else
          'title="Collapse all"'
        end
      end

      def css_class
        if @options[:button] && @options[:mini]
          %w[link br1 ph1 pv1 dib white bg-silver]
        elsif @options[:button]
          %w[link br1 ph2 pv2 dib white bg-silver]
        else
          %w[link]
        end
      end
    end
  end
end
