# frozen_string_literal: true

module Crossbeams
  module Layout
    # A text renderer - for rendering text without form controls.
    class Text # rubocop:disable Metrics/ClassLength
      include PageNode
      attr_reader :text, :page_config, :preformatted, :syntax, :wrapper,
                  :toggle_button, :toggle_caption, :toggle_element_id
      WRAP_START = {
        p: '<p>',
        h1: '<h1>',
        h2: '<h2>',
        h3: '<h3>',
        h4: '<h4>',
        i: '<em>',
        em: '<em>',
        b: '<strong>',
        strong: '<strong>'
      }.freeze
      WRAP_END = {
        p: '</p>',
        h1: '</h1>',
        h2: '</h2>',
        h3: '</h3>',
        h4: '</h4>',
        i: '</em>',
        em: '</em>',
        b: '</strong>',
        strong: '</strong>'
      }.freeze

      def initialize(page_config, text, opts = {})
        @text           = text
        @page_config    = page_config
        @nodes          = []
        @wrapper        = Array(opts[:wrapper] || :none)
        @preformatted   = opts[:preformatted] || false
        @syntax         = opts[:syntax]
        @toggle_button  = opts[:toggle_button] || false
        @toggle_caption = opts[:toggle_caption] || 'Show/Hide Text'
        @toggle_element_id = opts[:toggle_element_id]
        assert_element_id_in_text!
      end

      def assert_element_id_in_text!
        return nil if @toggle_element_id.nil?
        raise ArgumentError, 'toggle element id is not present in text' unless @text.match?(/id=['"]#{@toggle_element_id}['"]/)
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def preformatted!
        @preformatted = true
      end

      def render
        <<-HTML
        #{render_toggle_button}
        <div class="crossbeams-field no-flex"#{render_toggle_id}>
        #{preformatted || !syntax.nil? ? preformatted_text : render_text}
        </div>
        HTML
      end

      private

      def render_toggle_button
        return '' unless toggle_button
        <<~HTML
          <a href="#" class="f6 link dim br2 ph3 pv2 dib white bg-silver"
            onclick="crossbeamsUtils.toggleVisibility('#{toggle_id}');return false">
          #{info_icon} #{toggle_caption}</a>
        HTML
      end

      def info_icon
        Icon.render(:info)
      end

      def render_toggle_id
        return '' unless toggle_button
        return '' if  toggle_element_id
        " id='#{toggle_id}' hidden"
      end

      def toggle_id
        return '' unless toggle_button
        (toggle_element_id || toggle_caption).downcase.tr(' ', '_')
      end

      def preformatted_text
        <<~HTML
          <pre>
          #{render_text}
          </pre>
        HTML
      end

      def render_text
        if syntax.nil?
          wrap_text
        else
          render_with_highlighter
        end
      end

      def wrap_text
        if wrapper && wrapper != [:none]
          "#{wrapper.map { |w| WRAP_START[w] }.join}#{text}#{wrapper.reverse.map { |w| WRAP_END[w] }.join}"
        else
          text
        end
      end

      def render_with_highlighter
        theme = Rouge::Themes::Github
        formatter = Rouge::Formatters::HTMLInline.new(theme)
        lexer = case syntax
                when :ruby
                  Rouge::Lexers::Ruby.new
                when :sql
                  Rouge::Lexers::SQL.new
                when :yaml, :yml
                  Rouge::Lexers::YAML.new
                else
                  Rouge::Lexers::PlainText.new
                end
        formatter.format(lexer.lex(text))
      end
    end
  end
end
