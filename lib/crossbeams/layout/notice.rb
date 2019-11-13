# frozen_string_literal: true

module Crossbeams
  module Layout
    # A notice renderer - for rendering text in an error, warning or information box.
    class Notice
      include PageNode
      attr_reader :text, :page_config, :notice_type, :caption, :show_caption, :inline_caption, :within_field

      def initialize(page_config, text, opts = {})
        @text           = text
        @page_config    = page_config
        @nodes          = []
        @notice_type    = opts[:notice_type] || :info
        @caption        = opts[:caption] || @notice_type.to_s.capitalize
        @caption        = 'Note' if @caption == 'Info'
        @inline_caption = opts[:inline_caption]
        @show_caption   = opts.fetch(:show_caption, true)
        @within_field   = opts.fetch(:within_field, true)
        assert_valid_notice_type!
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        div_start = within_field ? '<div class="crossbeams-field">' : ''
        div_end = within_field ? '</div>' : ''
        css = "crossbeams-#{notice_type}-note"
        <<~HTML
          #{div_start}<div class='#{css}'>#{notice_caption}
            <p>#{inline_notice_caption}#{text}</p>
          </div>#{div_end}
        HTML
      end

      private

      VALID_TYPES = %i[info success warning error].freeze
      def assert_valid_notice_type!
        raise ArgumentError, "Crossbeams::Layout::Notice type must be one of these symbols: #{VALID_TYPES.join(', ')}" unless VALID_TYPES.include?(notice_type)
      end

      def notice_caption
        return '' unless show_caption
        return '' if inline_caption

        "<p><strong>#{caption}:</strong></p>"
      end

      def inline_notice_caption
        return '' unless show_caption
        return '' unless inline_caption

        "<strong>#{caption}:</strong> "
      end
    end
  end
end
