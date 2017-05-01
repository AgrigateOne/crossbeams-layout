module Crossbeams
  module Layout
    module Renderer
      # Render a Grid.
      class Grid < Base
        def initialize(grid_id, url, caption)
          @grid_id = grid_id
          @url     = url
          @caption = caption
        end
        # def configure(field_name, field_config, page_config)
        #   @field_name   = field_name
        #   @field_config = field_config
        #   @page_config  = page_config
        #   @caption      = field_config[:caption] || present_field_as_label(field_name)
        # end

        def render
          head_section = <<-EOH
        <div class="grid-head">
          <label style="margin-left: 20px;">
              <button class="pure-button" onclick="crossbeamsGridEvents.csvExport('#{@grid_id}', '#{file_name_from_caption(@caption)}')"><i class="fa fa-file"></i> Export to CSV</button>
          </label>
          <label style="margin-left: 20px;">
              <button class="pure-button" onclick="crossbeamsGridEvents.toggleToolPanel('#{@grid_id}')"><i class="fa fa-cog"></i> Tool panel</button>
          </label>
          <label style="margin-left: 20px;">
              <button class="pure-button" onclick="crossbeamsGridEvents.printAGrid('#{@grid_id}', '#{@url}')"><i class="fa fa-print"></i> Print</button>
          </label>
          <label style="margin-left: 20px;">
              <input class="un-formed-input" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-id="#{@grid_id}"/>
          </label>
          <span class="grid-caption">
            #{@caption}
          </span>
        </div>
          EOH
          <<-EOS
        <div style="height:40em">#{head_section}
          <div id="#{@grid_id}" style="height: 100%;" class="ag-blue" data-gridurl="#{@url}" data-grid="grid"></div>
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
end
