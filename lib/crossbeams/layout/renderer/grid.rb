# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Grid.
      class Grid < Base
        def initialize(grid_id, url, caption, nested_grid)
          @grid_id     = grid_id
          @url         = url
          @caption     = caption
          @nested_grid = nested_grid
        end
        # def configure(field_name, field_config, page_config)
        #   @field_name   = field_name
        #   @field_config = field_config
        #   @page_config  = page_config
        #   @caption      = field_config[:caption] || present_field_as_label(field_name)
        # end

        def self.header(grid_id, caption, options = {})
          if options[:print_button]
            raise ArgumentError, 'print_url is required to print a grid' unless options[:print_url]
            print_section = <<~EOS
              <label style="margin-left: 20px;">
                  <button class="pure-button" onclick="crossbeamsGridEvents.printAGrid('#{grid_id}', '#{options[:print_url]}')"><i class="fa fa-print"></i> Print</button>
              </label>
            EOS
          else
            print_section = ''
          end

          <<-EOH
          <div class="grid-head">
            <label style="margin-left: 20px;">
                <button class="crossbeams-to-fullscreen" onclick="crossbeamsGridEvents.toFullScreen('#{grid_id}')" title="show in fullscreen mode"><i class="fa fa-arrows-alt"></i></button>
            </label>
            <label style="margin-left: 20px;">
                <button class="crossbeams-view-row" onclick="crossbeamsGridEvents.viewSelectedRow('#{grid_id}')" title="view selected row"><i class="fa fa-eye"></i></button>
            </label>
            <label style="margin-left: 20px;">
                <button class="pure-button" onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{Grid.file_name_from_caption(caption)}')"><i class="fa fa-file"></i> Export to CSV</button>
            </label>
            <label style="margin-left: 20px;">
                <button class="pure-button" onclick="crossbeamsGridEvents.toggleToolPanel('#{grid_id}')"><i class="fa fa-cog"></i> Tool panel</button>
            </label>
            #{print_section}
            <label style="margin-left: 20px;">
                <input class="un-formed-input" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-id="#{grid_id}"/>
            </label>
            <label style="margin-left: 20px;">
                <select id='#{grid_id}-scrollcol' onchange="crossbeamsGridEvents.scrollToColumn(event)" data-grid-id="#{grid_id}"/>
                  <option value=''>Scroll to column</option>
                <select>
            </label>
            <span class="grid-caption">
              #{caption}
            </span>
            <span id="#{grid_id}_rowcount" class="crossbeams-rowcount"></span>
          </div>
          EOH
        end

        def render
          head_section = Grid.header(@grid_id, @caption, print_button: true, print_url: @url)
          <<~EOS
          <div id="#{@grid_id}-frame" style="height:40em">#{head_section}
            <div id="#{@grid_id}" style="height: 100%;" class="ag-blue" data-gridurl="#{@url}" data-grid="grid" #{denote_nested_grid}></div>
          </div>
          EOS
        end

        private

        def self.file_name_from_caption(caption)
          (caption || 'grid_contents').gsub('&nbsp;', 'grid_contents').gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.csv'
        end

        def denote_nested_grid
          @nested_grid ? 'data-nested-grid="y"' : ''
        end
      end
    end
  end
end
