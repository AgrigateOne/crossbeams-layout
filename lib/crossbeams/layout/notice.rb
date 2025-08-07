# frozen_string_literal: true

module Crossbeams
  module Layout
    # A notice renderer - for rendering text in an error, warning or information box.
    class Notice
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
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
        # css = "crossbeams-#{notice_type}-note"
        css = "#{SC.css_class(:notice)} #{SC.css_class("note_#{notice_type}")}"

        # <<~HTML
        #   #{div_start}<div class="#{css}">#{notice_caption}
        #     <p>#{inline_notice_caption}#{text}</p>
        #   </div>#{div_end}
        # HTML
        # <div class="flex flex-row justify-start items-center gap-2 px-3 py-4 mb-4 rounded bg-red-100 text-red-700">
        <<~HTML
          #{div_start}<div class="#{css}">
            #{Icon.new(:info).render}
            <p>#{notice_caption}#{inline_notice_caption}#{text}</p>
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

        # %(<p><strong class="#{SC.css_class(:strong)}">#{caption}:</strong></p>)
        %(<strong class="#{SC.css_class(:strong)}">#{caption}:</strong><br>)
      end

      def inline_notice_caption
        return '' unless show_caption
        return '' unless inline_caption

        %(<strong class="#{SC.css_class(:strong)}">#{caption}:</strong> )
      end
    end
  end
end
