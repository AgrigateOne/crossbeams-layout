module Crossbeams
  module Layout

    class Grid
      attr_reader :grid_id, :url, :page_config, :options

      def initialize(page_config, grid_id, url, options={})
        @grid_id     = grid_id
        @url         = url
        @page_config = page_config
        @options     = options
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
        # buttons << "<input type='text' id='#{@grid_id}search' placeholder='Search...' style='width:100px;margin-left:5px;margin-right:5px;vertical-align:top;' />"
        #<input onkeyup="crossbeamsGridEvents.quickSearch('#{grid_id}', this)" placeholder='Search...' />

        head_section = <<-EOH
      <div class="grid-head">
        <label style="margin-left: 20px;">
            <button onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{file_name_from_caption(caption)}')">Export to CSV</button>
        </label>
        <label style="margin-left: 20px;">
            <button onclick="crossbeamsGridEvents.toggleToolPanel('#{grid_id}')">Tool panel</button>
        </label>
        <label style="margin-left: 20px;">
            <button onclick="crossbeamsGridEvents.printAGrid('#{grid_id}', '#{url}')">Print</button>
        </label>
        <label style="margin-left: 20px;">
            <input onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-id="#{grid_id}"/>
        </label>
        #{caption}
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
        (caption || 'grid_contents').gsub('&nbsp;','grid_contents').gsub(/[\/:*?"\\<>\|\r\n]/i, '-') << '.csv'
      end

    end

  end

end
