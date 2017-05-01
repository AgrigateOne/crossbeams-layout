module Crossbeams
  module Layout
    # A CallbackSection is a section that does not render itself,
    # but calls an actin to render within the section once the page is loaded.
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

      def invisible?
        false
      end

      def hidden?
        false
      end

      # This render uses XHR via javascript
      # def render
      #   <<-EOS
      #   <section id="section-#{sequence}" data-crossbeams_callback_section="#{url}" class="crossbeams_layout">
      #   <h2>#{caption}</h2>
      #   <div class="content-target content-loading"></div>
      #   </section>
      #   EOS
      # end

      # This render uses inline javascript fetch.
      def render
        <<-EOS
      <section id="section-#{sequence}" class="crossbeams_layout">
      <h2>#{caption}</h2>
      <div id="crossbeams_callback_target_#{sequence}" class="content-target content-loading"></div>
      </section>
      <script>
        var content_div = document.querySelector('#crossbeams_callback_target_#{sequence}');

        fetch('#{url}')
        .then(function(response) {
          return response.text();
        })
        .then(function(responseText) {
          content_div.classList.remove('content-loading');
          content_div.innerHTML = responseText;
        });
      </script>
        EOS
      end
    end
  end
end
