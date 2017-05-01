module Crossbeams
  module Layout
    # A text renderer - for rendering text without form controls.
    class Text
      include PageNode
      attr_reader :text, :page_config

      def initialize(page_config, text)
        @text        = text
        @page_config = page_config
        @nodes       = []
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        <<-EOS
        <div class="crossbeams-field">
          #{text}
        </div>
        EOS
      end
    end
  end
end
