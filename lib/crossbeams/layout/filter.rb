# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Filter that contains fields
    class Filter
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf

      attr_reader :nodes, :dom_id

      def initialize
        @dom_id = "filter-#{SecureRandom.hex(4)}"
        @nodes = []
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def url(url)
        @url = url
      end

      def target_dom_id(val)
        @target_dom_id = val
      end

      def add_filter(name, options = {})
        @nodes << FilterField.new(name, options)
      end

      def render
        raise Crossbeams::FrameworkError, "#{self} - a url must be provided" unless @url
        raise Crossbeams::FrameworkError, "#{self} - a target DOM id must be provided" unless @target_dom_id

        filter_renders = nodes.reject(&:invisible?).map(&:render).join("\n")
        params = selected_params
        text = selected_param_texts

        <<~HTML
          <div class="flex gap-2 items-top justify-end mb-2" data-page-filter="Y" data-filter-for-dom-id="#{@target_dom_id}" data-filter-url="#{@url}">
            <div class="p-2">Filter:</div>
            #{filter_renders}
            <button class="hidden #{SC.css_class(:button_primary).sub('flex ', '')}" data-filter-btn-apply="Y">Apply</button>
            <button class="hidden #{SC.css_class(:button_secondary).sub('flex ', '')}" data-filter-btn-clear="Y">Clear</button>
            <input type="hidden" name="#{dom_id}_values" value="#{params}" />
            <input type="hidden" name="#{dom_id}_text" value="#{text}" />
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

      private

      def selected_params
        params = {}
        ar = @nodes.map { |node| node.selected_params if node.respond_to?(:selected_params) } # selected_params returns [fieldname, val]
        ar.compact.each do |field, values|
          params[field] = values
        end
        params
      end

      def selected_param_texts
        ar = @nodes.map { |node| node.selected_param_texts if node.respond_to?(:selected_param_texts) } # selected_params returns "Caption: VAL, VAL"
        ar.compact.join(';')
      end
    end
  end
end
