# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Grid.
      class Grid < Base
        def initialize(grid_id, url, caption, options = {})
          @grid_id     = grid_id
          @url         = url
          @caption     = caption
          @nested_grid = options[:nested_grid]
          @multiselect = options[:is_multiselect]
          @multiselect_url = options[:multiselect_url]
          @multiselect_key = options[:multiselect_key]
          @multiselect_params = options[:multiselect_params]
          @query_string = options[:grid_params].nil? ? nil : options[:grid_params][:query_string]
          @can_be_cleared = options[:can_be_cleared] || false
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
            print_section = <<~HTML
              <label style="margin-left: 20px;">
                  <button class="pure-button" onclick="crossbeamsGridEvents.printAGrid('#{grid_id}', '#{options[:print_url]}')"><i class="fa fa-print"></i> Print</button>
              </label>
            HTML
          else
            print_section = ''
          end

          <<-HTML
          <div class="grid-head">
            <label style="margin-left: 20px;">
                <button class="crossbeams-to-fullscreen" onclick="crossbeamsGridEvents.toFullScreen('#{grid_id}')" title="show in fullscreen mode"><i class="fa fa-arrows-alt"></i></button>
            </label>
            <label style="margin-left: 20px;">
                <button class="crossbeams-view-row" onclick="crossbeamsGridEvents.viewSelectedRow('#{grid_id}')" title="view selected row"><i class="fa fa-eye"></i></button>
            </label>#{save_multiselect_button(grid_id, options)}
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
          HTML
        end

        def render
          head_section = Grid.header(@grid_id, @caption,
                                     print_button: true,
                                     print_url: @url,
                                     multiselect: @multiselect,
                                     multiselect_url: @multiselect_url,
                                     can_be_cleared: @can_be_cleared)
          <<~HTML
            <div id="#{@grid_id}-frame" style="height:20em">#{head_section}
              <div id="#{@grid_id}" style="height: 100%;" class="ag-blue" data-gridurl="#{url}" data-grid="grid" #{denote_nested_grid} #{denote_multiselect} onload="console.log('onl'); "></div>
              <script>console.log('loaded #{@grid_id}');</script>
            </div>
          HTML
        end

        private_class_method

        def self.file_name_from_caption(caption)
          (caption || 'grid_contents').gsub('&nbsp;', 'grid_contents').gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.csv'
        end

        def self.save_multiselect_button(grid_id, options)
          return '' unless options[:multiselect]
          <<~HTML
            <label style="margin-left: 20px;">
                <button class="crossbeams-view-savemulti" onclick="crossbeamsGridEvents.saveSelectedRows('#{grid_id}', '#{options[:multiselect_url]}', #{options[:can_be_cleared] == true})" title="save selection"><i class="fa fa-save"></i></button>
            </label>
          HTML
        end

        private

        def url
          return @url if @multiselect.nil? && @query_string.nil?
          return "#{@url}?#{@query_string}" unless @query_string.nil?
          parms = []
          @multiselect_params.each do |k, v|
            parms << "#{k}=#{v}" unless k == :key
          end
          qstr = parms.empty? ? '' : "?#{parms.join('&')}"
          "#{@url}/#{@multiselect_key}#{qstr}"
        end

        def denote_nested_grid
          @nested_grid ? 'data-nested-grid="y"' : ''
        end

        def denote_multiselect
          @multiselect ? "data-grid-multi=\"#{@multiselect_key}\"" : ''
        end
      end
    end
  end
end
