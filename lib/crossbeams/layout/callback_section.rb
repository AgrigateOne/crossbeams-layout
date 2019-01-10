# frozen_string_literal: true

module Crossbeams
  module Layout
    # A CallbackSection is a section that does not render itself,
    # but calls an action to render within the section once the page is loaded.
    class CallbackSection
      include PageNode
      attr_accessor :caption, :url
      attr_reader :sequence, :page_config

      def initialize(page_config, sequence)
        @caption  = 'Section'
        @sequence = sequence
        @page_config = page_config
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

      # Render the control
      def render
        <<-HTML
          <section id="section-#{sequence}" class="crossbeams_layout">
          <h2>#{caption}</h2>
          <div id="crossbeams_callback_target_#{sequence}" class="content-target content-loading">
            <div></div><div></div><div></div>
          </div>
          </section>
          <script>
            document.addEventListener('DOMContentLoaded', () => {
              crossbeamsUtils.loadCallBackSection('#crossbeams_callback_target_#{sequence}', '#{url}');
            });
          </script>
        HTML
      end
    end
  end
end
