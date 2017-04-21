module Crossbeams
  module Layout
    class Text
      attr_reader :text, :page_config

      def initialize(page_config, text)
        @text        = text
        @page_config = page_config
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
