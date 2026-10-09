# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Page obejct holds all other layout elemnts.
    class RMDPage # rubocop:disable Metrics/ClassLength
      attr_reader :nodes, :page_config, :sequence, :progress_prefix, :progress_val, :progress_max

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
      def self.build(rmd_state = { scan_with_camera: false }, &block)
        new.build(rmd_state, &block)
      end

      # Build a page.
      # Passes the page instance and page_config to the block.
      def build(rmd_state)
        @scan_with_camera = rmd_state[:scan_with_camera]
        notices_from_hash(rmd_state)
        @validation_errors = rmd_state[:rmd_validation]
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
        form.errors @validation_errors
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

      def notices(obj)
        return notices_from_hash if obj.is_a?(Hash)

        notices_from_entity(obj)
      end

      def notices_from_hash(hash)
        info_notice hash[:info_notice]
        success_notice hash[:success_notice]
        warning_notice hash[:warning_notice]
        error_notice hash[:error_notice]
      end

      def notices_from_entity(entity) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        info_notice entity.info_notice if entity.respond_to?(:info_notice) && entity.info_notice
        success_notice entity.success_notice if entity.respond_to?(:success_notice) && entity.success_notice
        warning_notice entity.warning_notice if entity.respond_to?(:warning_notice) && entity.warning_notice
        error_notice entity.error_notice if entity.respond_to?(:error_notice) && entity.error_notice
      end

      def notes(value)
        @notes = value
      end

      def step_and_total(step, total)
        @step_number = step
        @step_count = total
      end

      def progress_indicator(val, max, prefix: nil)
        raise ArgumentError, 'RMDPage#progress_indicator - val and max must be integers' unless val.is_a?(Integer) && max.is_a?(Integer)
        raise ArgumentError, 'RMDPage#progress_indicator - max cannot be zero' if max.zero?
        raise ArgumentError, 'RMDPage#progress_indicator - val and max cannot be negative' if val.negative? || max.negative?

        @progress_prefix = prefix
        @progress_val = val
        @progress_max = max
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
          #{progress_bar}
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

      def progress_bar
        return '' if progress_max.nil?

        text = "#{progress_prefix} #{progress_val} of #{progress_max}".lstrip
        perc = progress_val / progress_max.to_f * 100.0
        <<~HTML
          <div class="-ml-2 my-2 relative w-full h-6 bg-sky-50 rounded-lg overflow-hidden">
            <div class="h-full bg-ocean-700 opacity-50 rounded-lg" style="width: #{perc}%;"></div>
            <span class="absolute inset-0 flex items-center justify-center text-sm font-medium text-slate-800">
              #{text}
            </span>
          </div>
        HTML
      end

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
