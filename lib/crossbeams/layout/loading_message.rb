# frozen_string_literal: true

module Crossbeams
  module Layout
    # Display a message to show that something is being loaded
    class LoadingMessage
      attr_reader :caption, :options

      def initialize(options = {})
        @caption = options[:caption]
        @options = options
      end

      def render
        <<~HTML
          <div#{dom_id} class="content-target content-loading">
            <div></div><div></div><div></div>#{render_caption}
          </div>
        HTML
      end

      private

      def dom_id
        return '' unless options[:dom_id]

        %( id="#{options[:dom_id]}")
      end

      def render_caption
        return caption unless options[:wrap_for_centre]

        %(<p class="pa3">#{caption}</p>)
      end
    end
  end
end
