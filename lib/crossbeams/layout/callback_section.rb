# frozen_string_literal: true

module Crossbeams
  module Layout
    # A CallbackSection is a section that does not render itself,
    # but calls an action to render within the section once the page is loaded.
    class CallbackSection
      extend MethodBuilder

      build_methods_for :csrf
      attr_accessor :caption, :url
      attr_reader :sequence, :page_config

      def initialize(page_config, sequence)
        @caption  = 'Section'
        @sequence = sequence
        @page_config = page_config
        @remote = false
        @nodes       = []
      end

      # Is this control invisible?
      def invisible?
        false
      end

      # Is this control hidden?
      def hidden?
        false
      end

      def remote!
        @remote = true
      end

      def caption_text(caption)
        @caption = caption
      end

      def callback_url(url)
        @url = url
      end

      # Render the control
      def render
        return remote_render if @remote

        <<-HTML
          <section id="section-#{sequence}" class="crossbeams_layout">
          <h2>#{caption}</h2>
          #{LoadingMessage.new(dom_id: "crossbeams_callback_target_#{sequence}").render}
          </section>
          <script>
            document.addEventListener('DOMContentLoaded', () => {
              crossbeamsUtils.loadCallBackSection('#crossbeams_callback_target_#{sequence}', '#{url}');
            });
          </script>
        HTML
      end

      # Render the control in a dialog
      def remote_render
        <<-HTML
          <section id="section-#{sequence}" class="crossbeams_layout" data-callback-section-url="#{url}">
          <h2>#{caption}</h2>
          #{LoadingMessage.new(dom_id: "crossbeams_callback_target_#{sequence}").render}
          </section>
        HTML
      end
    end
  end
end
