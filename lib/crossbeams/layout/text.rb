# frozen_string_literal: true

module Crossbeams
  module Layout
    # A text renderer - for rendering text without form controls.
    class Text
      include PageNode
      attr_reader :text, :page_config, :preformatted, :syntax, :wrapper
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
        @text         = text
        @page_config  = page_config
        @nodes        = []
        @wrapper      = Array(opts[:wrapper] || :none)
        @preformatted = opts[:preformatted] || false
        # @preformatted = opts.fetch(:preformatted) { false }
        @syntax       = opts[:syntax]
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
        <div class="crossbeams-field">
        #{preformatted || !syntax.nil? ? preformatted_text : render_text}
        </div>
        HTML
      end

      private

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
