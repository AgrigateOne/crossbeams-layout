# frozen_string_literal: true

module Crossbeams
  module Layout
    # A line of click-able tabs
    class TabSet
      attr_reader :items, :active_tab_index, :target_dom_id, :preloaded_tabs

      def initialize(page_config, items, options = {})
        @page_config = page_config
        @items = Array(items)
        @active_tab_index = options[:active_tab_index] || 0
        @target_dom_id = options[:target_dom_id]
        @preloaded_tabs = options[:preloaded_tabs] || false
        validate_options(options)
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

      def add_csrf_tag(tag)
        # noop
      end

      # Render a set of Tabs
      # @return [string] the HTML for a set of tabs
      def render
        <<~HTML
          <div class="my-4">
            <ul class="flex">
              #{render_items}
            </ul>
          </div>
        HTML
      end

      private

      def render_items # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        items.map.with_index do |item, index|
          state_class = index == active_tab_index ? 'text-ocean-700 border-ocean-700 border-b-3' : 'text-slate-500 hover:text-slate-600 hover:border-slate-300 hover:border-b-3 cursor-pointer'
          active = index == active_tab_index ? 'Y' : 'N'
          remote = item[:remote] ? 'Y' : 'N'
          target = item[:remote] ? target_dom_id : ''
          target = item[:preload_dom_id] if preloaded_tabs
          preload = preloaded_tabs ? 'Y' : 'N'
          <<~HTML
            <li class="inline-block p-2 min-w-28 text-xl font-medium text-center #{state_class}"
                data-tabset-url="#{item[:url]}"
                data-tabset-active="#{active}"
                data-tabset-remote="#{remote}"
                data-tabset-target="#{target}"
                data-tabset-preload="#{preload}">
              #{item[:text]}
            </li>
          HTML
        end.join("\n")
      end

      def validate_options(options) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        required_keys = preloaded_tabs ? [:text] : %i[text url]
        raise ArgumentError, 'TabSet: All items must have :text and :url attributes' unless items.all? { |i| (i.keys & required_keys) == required_keys }
        raise ArgumentError, 'TabSet: A target DOM id is required for remote tab items' if options[:target_dom_id].nil? && items.any? { |i| i[:remote] }
        raise ArgumentError, 'TabSet: A preload DOM id is required for preloaded tab items' if options[:preloaded_tabs].nil? && items.any? { |i| i[:preload_dom_id].nil? }
        raise ArgumentError, "TabSet: Active tab index is out of range (0..#{items.length - 1} permitted)" if options[:active_tab_index] && (options[:active_tab_index] > items.length || options[:active_tab_index].negative?)
      end
    end
  end
end
