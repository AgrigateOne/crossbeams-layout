# frozen_string_literal: true

module Crossbeams
  module Layout
    # A text renderer - for rendering text without form controls.
    class Text # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :text, :page_config, :preformatted, :syntax, :wrapper,
                  :toggle_button, :toggle_caption, :toggle_element_id,
                  :options, :wrapper_classes, :external_toggle_element

      WRAP_START = {
        p: '<p%s>',
        h1: '<h1%s>',
        title_large: '<h1%s>',
        h2: '<h2%s>',
        title_medium: '<h2%s>',
        h3: '<h3%s>',
        title_small: '<h3%s>',
        h4: '<h4%s>',
        title_x_small: '<h4%s>',
        i: '<em%s>',
        em: '<em%s>',
        b: '<strong%s>',
        strong: '<strong%s>',
        small: '<p>'
      }.freeze
      MARGIN_KEYS = %i[p h1 title_large h2 title_medium h3 title_small h4 title_x_small].freeze
      WRAP_END = {
        p: '</p>',
        h1: '</h1>',
        title_large: '</h1>',
        h2: '</h2>',
        title_medium: '</h2>',
        h3: '</h3>',
        title_small: '</h3>',
        h4: '</h4>',
        title_x_small: '</h4>',
        i: '</em>',
        em: '</em>',
        b: '</strong>',
        strong: '</strong>',
        small: '</p>'
      }.freeze
      WRAP_CLASS = {
        # p: '</p>',
        h1: SC.css_class(:h1),
        title_large: SC.css_class(:h1),
        h2: SC.css_class(:h2),
        title_medium: SC.css_class(:h2),
        h3: SC.css_class(:h3),
        title_small: SC.css_class(:h3),
        h4: SC.css_class(:h4),
        title_x_small: SC.css_class(:h4),
        i: SC.css_class(:em),
        em: SC.css_class(:em),
        b: SC.css_class(:strong),
        strong: SC.css_class(:strong),
        small: SC.css_class(:bodycopy_small)
      }.freeze

      def initialize(page_config, text, opts = {})
        @text = text
        @page_config = page_config
        @nodes = []
        @wrapper = Array(opts[:wrapper] || :none)
        @wrapper_classes = opts[:wrapper_classes]
        @preformatted = opts[:preformatted] || false
        @syntax = opts[:syntax]
        @toggle_button = opts[:toggle_button] || false
        @toggle_caption = opts[:toggle_caption] || 'Show/Hide Text'
        @toggle_element_id = opts[:toggle_element_id]
        @external_toggle_element = opts[:external_toggle_element]
        @options = opts
        assert_element_id_in_text!
      end

      def assert_element_id_in_text!
        return nil if @toggle_element_id.nil?
        return nil if external_toggle_element
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
        <div class="crossbeams-field no-flex#{css_classes}#{wrapper_visibility}"#{render_toggle_id}#{wrapper_id}>
        #{preformatted || !syntax.nil? ? preformatted_text : render_text}
        </div>
        HTML
      end

      private

      # Initially hide the wrapper.
      def wrapper_visibility
        @options[:hide_on_load] = !@options[:initially_visible] if @options&.key?(:initially_visible)
        return '' unless @options[:hide_on_load]

        ' hidden'
      end

      def wrapper_id
        return '' unless @options[:dom_id]

        %( id="#{@options[:dom_id]}")
      end

      def css_classes
        return '' unless @options[:css_classes]

        " #{@options[:css_classes]}"
      end

      def render_toggle_button
        return '' unless toggle_button

        # Tachy: <a href="#" class="f6 link dim br2 ph3 pv2 dib white bg-silver"
        # <a href="#" class="text-sm no-underline rounded px-4 py-2 inline-block text-slate-800 bg-slate-300 hover:text-french-blue-600 hover:bg-steel-blue-100"
        # <a href="#" class="text-sm no-underline rounded px-4 py-2 inline-block text-slate-800 bg-slate-300 hover:text-blue-600 hover:bg-blue-100"
        # <<~HTML
        #  <a href="#" class="text-sm no-underline rounded px-4 py-2 inline-block text-slate-800 bg-slate-300 hover:text-french-blue-600 hover:bg-steel-blue-100"
        #    onclick="crossbeamsUtils.toggleVisibility('#{toggle_id}');return false">
        #  #{info_icon} #{toggle_caption}</a>
        # HTML
        # <button class="flex items-center justify-center gap-3 flex-row rounded border-2 h-11 p-3 font-medium text-slate-800 bg-slate-300 hover:text-french-blue-600 hover:bg-steel-blue-100"
        <<~HTML
          <button class="inline-block #{SC.css_class(:button_secondary)}"
            onclick="crossbeamsUtils.toggleVisibility('#{toggle_id}');return false">
            #{info_icon} #{toggle_caption}
          </button>
        HTML
      end

      def info_icon
        Icon.render(:info)
      end

      def render_toggle_id
        return '' unless toggle_button
        return '' if toggle_element_id

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
          "#{wrapper.map { |w| format(WRAP_START[w], wrap_class(w)) }.join}#{text}#{wrapper.reverse.map { |w| WRAP_END[w] }.join}"
        else
          text
        end
      end

      def wrap_class(wrap)
        cls = [WRAP_CLASS[wrap], wrapper_classes].compact.join(' ')
        return '' if cls.empty?

        %( class="#{cls}#{margin(wrap)}")
      end

      def margin(wrap)
        return '' unless MARGIN_KEYS.include?(wrap)

        ' my-2'
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
                when :xml
                  Rouge::Lexers::XML.new
                when :json
                  Rouge::Lexers::JSON.new
                else
                  Rouge::Lexers::PlainText.new
                end
        formatter.format(lexer.lex(text))
      end
    end
  end
end
