# frozen_string_literal: true

module Crossbeams
  module Layout
    # A page can optionally contain one or more sections.
    class Section
      include PageNode
      attr_accessor :caption, :hide_caption, :show_border
      attr_reader :sequence, :nodes, :page_config, :fit_height

      def initialize(page_config, sequence)
        @caption      = 'Section'
        @sequence     = sequence
        @nodes        = []
        @page_config  = page_config
        @hide_caption = true
        @show_border  = false
        @fit_height   = false
        @css_classes  = ['pa2']
      end

      def add_caption(caption)
        @caption = caption
        @hide_caption = false
      end

      def show_border!
        @show_border = true
      end

      def fit_height!
        @fit_height = true
      end

      def invisible?
        @nodes.all?(&:invisible?)
      end

      def hidden?
        @nodes.all?(&:hidden?)
      end

      def form
        form = Form.new(page_config, sequence, nodes.length + 1)
        yield form
        @nodes << form
      end

      def row
        row = Row.new(page_config, sequence, nodes.length + 1)
        yield row
        @nodes << row
      end

      def add_grid(grid_id, url, options = {})
        @nodes << Grid.new(page_config, grid_id, url, options.merge(fit_height: @fit_height))
      end

      def add_text(text, opts = {})
        @nodes << Text.new(page_config, text, opts)
      end

      def add_notice(text, opts = {})
        @nodes << Notice.new(page_config, text, opts)
      end

      # Add a table to the section.
      def add_table(rows, columns, options = {})
        @nodes << Table.new(page_config, rows, columns, options)
      end

      # Add a progress_step to the section.
      def add_progress_step(steps, options = {})
        @nodes << ProgressStep.new(page_config, steps, options)
      end

      # Add a repeating request to the section.
      def add_repeating_request(url, interval, content)
        @nodes << RepeatingRequest.new(page_config, url, interval, content)
      end

      def add_address(addresses, opts = {})
        @nodes << Address.new(page_config, addresses, opts)
      end

      def add_contact_method(contact_methods, options = {})
        @nodes << ContactMethod.new(page_config, contact_methods, options)
      end

      def add_diff(key)
        @nodes << Diff.new(page_config, key)
      end

      # Add a control (button, link) to the page.
      #
      # @return [void]
      def add_control(page_control_definition)
        @nodes << Link.new(page_control_definition) if page_control_definition[:control_type] == :link
      end

      def render
        row_renders = nodes.reject(&:invisible?).map(&:render).join("\n")
        add_extra_css_classes

        <<~HTML
          #{render_fit_height_caption}
          <section id="section-#{sequence}" class="#{@css_classes.join(' ')}">
          #{render_normal_caption}
            #{row_renders}
          </section>
        HTML
      end

      private

      def render_fit_height_caption
        render_caption if @fit_height
      end

      def render_normal_caption
        render_caption unless @fit_height
      end

      def render_caption
        return '' if hide_caption
        "<h2 class='ma1'>#{caption}</h2>"
      end

      def add_extra_css_classes
        @css_classes << 'crossbeams_layout-border' if show_border
        @css_classes << 'crossbeams_layout-fit-height' if fit_height
      end
    end
  end
end
