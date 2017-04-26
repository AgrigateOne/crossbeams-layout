module Crossbeams
  module Layout
    # Render a data grid in the Page.
    class Grid
      attr_reader :grid_id, :url, :page_config, :options

      def initialize(page_config, grid_id, url, options = {})
        @grid_id     = grid_id
        @url         = url
        # puts ">>> GRID URL: #{url}"
        @page_config = page_config
        @options     = options
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        if options[:for_print]
          render_for_print
        else
          render_for_screen
        end
      end

      def render_for_print
        puts ">>> In grid: #{page_config.options.inspect}"
        <<-EOS
        <div id="#{grid_id}" style="height: 100%;" class="ag-blue" data-gridurl="#{page_config.options[:grid_url]}" data-grid="grid" data-grid-print="forPrint"></div>
        EOS
      end

      def render_for_screen
        caption = options[:caption]

        head_section = <<-EOH
      <div class="grid-head">
        <label style="margin-left: 20px;">
            <button class="pure-button" onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{file_name_from_caption(caption)}')"><i class="fa fa-file"></i> Export to CSV</button>
        </label>
        <label style="margin-left: 20px;">
            <button class="pure-button" onclick="crossbeamsGridEvents.toggleToolPanel('#{grid_id}')"><i class="fa fa-cog"></i> Tool panel</button>
        </label>
        <label style="margin-left: 20px;">
            <button class="pure-button" onclick="crossbeamsGridEvents.printAGrid('#{grid_id}', '#{url}')"><i class="fa fa-print"></i> Print</button>
        </label>
        <label style="margin-left: 20px;">
            <input class="un-formed-input" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-id="#{grid_id}"/>
        </label>
        <span class="grid-caption">
          #{caption}
        </span>
      </div>
        EOH
        <<-EOS
      <div style="height:40em">#{head_section}
        <div id="#{grid_id}" style="height: 100%;" class="ag-blue" data-gridurl="#{url}" data-grid="grid"></div>
      </div>
        EOS
      end

      private

      def file_name_from_caption(caption)
        (caption || 'grid_contents').gsub('&nbsp;', 'grid_contents').gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') << '.csv'
      end
    end
  end
end
