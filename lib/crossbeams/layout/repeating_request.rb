# frozen_string_literal: true

module Crossbeams
  module Layout
    # Renders a div and repeatedly calls a URL via an interval.
    class RepeatingRequest
      extend MethodBuilder

      build_methods_for :csrf
      attr_reader :page_config, :url, :interval, :content

      def initialize(page_config, url, interval, content)
        @page_config = page_config
        @nodes       = []
        @url         = url
        @interval    = interval
        @content     = content
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
        <<-HTML
          <div class="w-100" data-poll-message-url="#{url}" data-poll-message-interval="#{interval}">
            #{content}
          </div>
        HTML
      end
    end
  end
end
