# frozen_string_literal: true

module Crossbeams
  module Layout
    # Renders a div and repeatedly calls a URL via an interval.
    class RepeatingRequest
      extend MethodBuilder

      build_methods_for :csrf
      attr_reader :page_config, :url, :interval, :content, :options

      def initialize(page_config, url, interval, content, options = {})
        @page_config = page_config
        @nodes = []
        @url = url
        @interval = interval
        @content = content
        @options = options
      end

      # Is this control invisible?
      def invisible?
        false
      end

      # Is this control hidden?
      def hidden?
        false
      end

      # Render the control
      def render
        cls = options[:css_classes] || 'w-100'
        <<-HTML
          <div class="#{cls}" data-poll-message-url="#{url}" data-poll-message-interval="#{interval}">
            #{content}
          </div>
        HTML
      end
    end
  end
end
