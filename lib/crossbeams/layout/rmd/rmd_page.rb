# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Page obejct holds all other layout elemnts.
    class RMDPage
      attr_reader :nodes, :page_config, :sequence

      SC = StylesConfig

      RenderNode = Struct.new(:str) do
        def render
          str
        end

        def add_csrf_tag(_)
          # NOOP
        end

        def invisible?
          false
        end
      end

      def initialize
        @nodes = []
      end

      # Build a page. Instantiates a Page and calls build on it.
      # @param [options]
      def self.build(scan_with_camera = false, &block) # rubocop:disable Style/OptionalBooleanParameter
        new.build(scan_with_camera, &block)
      end

      # Build a page.
      # Passes the page instance and page_config to the block.
      def build(scan_with_camera = false) # rubocop:disable Style/OptionalBooleanParameter
        @scan_with_camera = scan_with_camera
        yield self
        self
      end

      # Does the page or any of its nodes include javascript?
      def includes_javascript?
        false
      end

      # Iterate through all nodes and add the CSRF tag to them.
      # (Only Form objects should actually do something with this.
      def add_csrf_tag(tag)
        @nodes.each { |node| node.add_csrf_tag(tag) }
      end

      # Define a form in the page.
      def form
        form = RMDForm.new
        form.scan_with_camera(@scan_with_camera)
        yield form
        @nodes << form
      end

      def title(value)
        @title = value
      end

      def info_notice(value, options = {})
        @info = value
        @info_caption = options[:caption] if options[:caption]
      end

      def success_notice(value, options = {})
        @success = value
        @success_caption = options[:caption] if options[:caption]
      end

      def warning_notice(value, options = {})
        @warning = value
        @warning_caption = options[:caption] if options[:caption]
      end

      def error_notice(value, options = {})
        @error = value
        @error_caption = options[:caption] if options[:caption]
      end

      def notes(value)
        @notes = value
      end

      def step_and_total(step, total)
        @step_number = step
        @step_count = total
      end

      def table(recs)
        tr_cls_o = SC.css_class(:rmd_table_row_odd)
        tr_cls_e = SC.css_class(:rmd_table_row_even)
        th_cls = SC.css_class(:rmd_table_td_label)
        td_cls = SC.css_class(:rmd_table_td_value)
        rows = []
        recs.each_with_index do |rec, idx|
          tr_cls = idx.even? ? tr_cls_e : tr_cls_o
          rows << %(<tr class="#{tr_cls}"><td class="#{th_cls}">#{rec.first}</td><td class="#{td_cls}">#{rec.last}</td></tr>)
        end
        str = <<~HTML
          <div class="#{SC.css_class(:rmd_table_div)}">
            <table class="#{SC.css_class(:rmd_table)}">
            <tbody>
              #{rows.join("\n")}
            </tbody>
            </table>
          </div>
        HTML
        @nodes << RenderNode.new(str: str)
      end

      def add_text(text)
        @nodes << RenderNode.new(str: text)
      end

      def button_link(url, text)
        str = <<~HTML
          <div class="mt-2 flex flex-row gap-4 justify-end flex-wrap py-5">
            <a href="#{url}" class="#{SC.css_class(:button_primary)} w-full text-center">#{text}</a>
          </div>
        HTML
        @nodes << RenderNode.new(str: str)
      end

      # Render the page and all its child nodes.
      def render
        <<~HTML
          <h1 class="#{SC.css_class(:h1)}">#{@title}#{page_number_and_page_count}</h1>
          #{notes_section}
          #{info_section}
          #{success_section}
          #{warning_section}
          #{error_section}
          #{nodes.reject(&:invisible?).map(&:render).join("\n")}
        HTML
      end

      private

      def notes_section
        return '' unless @notes

        %(<p class="p-3">#{@notes.gsub("\n", '<br>')}</p>)
      end

      def info_section
        return '' unless @info

        if @info_caption
          Crossbeams::Layout::Notice.new({}, @info, notice_type: :info, caption: @info_caption).render
        else
          Crossbeams::Layout::Notice.new({}, @info, notice_type: :info, show_caption: false).render
        end
      end

      def success_section
        return '' unless @success

        if @success_caption
          Crossbeams::Layout::Notice.new({}, @success, notice_type: :success, caption: @success_caption).render
        else
          Crossbeams::Layout::Notice.new({}, @success, notice_type: :success, show_caption: false).render
        end
      end

      def warning_section
        return '' unless @warning

        if @warning_caption
          Crossbeams::Layout::Notice.new({}, @warning, notice_type: :warning, caption: @warning_caption).render
        else
          Crossbeams::Layout::Notice.new({}, @warning, notice_type: :warning, show_caption: false).render
        end
      end

      def error_section
        return '' unless @error

        if @error_caption
          Crossbeams::Layout::Notice.new({}, @error, notice_type: :error, caption: @error_caption).render
        else
          Crossbeams::Layout::Notice.new({}, @error, notice_type: :error, show_caption: false).render
        end
      end

      def page_number_and_page_count
        return '' if @step_count.nil?

        %(<span class="text-slate-600"> &ndash; (step #{@step_number} of #{@step_count})</span>)
      end
    end
  end
end
