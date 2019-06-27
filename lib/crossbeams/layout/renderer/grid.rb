# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Grid.
      class Grid < Base # rubocop:disable Metrics/ClassLength
        def initialize(grid_id, url, caption, options = {})
          @grid_id     = grid_id
          @url         = url
          @caption     = caption
          @nested_grid = options[:nested_grid]
          @query_string = options[:grid_params].nil? ? nil : options[:grid_params][:query_string]
          # Prevent a grid height less than 6em, default to 20.
          @height = [(options[:height] || 20), 6].max
          @fit_height = options[:fit_height] || false
          @tree_config = options[:tree]
          unpack_multiselect_options(options)
          unpack_lookup_options(options)
        end

        def self.header(grid_id, caption, options = {})
          if options[:print_button]
            raise ArgumentError, 'print_url is required to print a grid' unless options[:print_url]

            print_section = <<~HTML
              <label style="margin-left: 10px;">
                <button class="pure-button" onclick="crossbeamsGridEvents.printAGrid('#{grid_id}', '#{options[:print_url]}')" title="Print"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 16H0V6h20v10h-4v4H4v-4zm2-4v6h8v-6H6zM4 0h12v5H4V0zM2 8v2h2V8H2zm4 0v2h2V8H6z"/></svg>
                </button>
              </label>
            HTML
          else
            print_section = ''
          end

          <<-HTML
          <div class="grid-head">
            <label style="margin-left: 10px;">
               <button class="crossbeams-to-fullscreen" onclick="crossbeamsGridEvents.toFullScreen('#{grid_id}')" title="show in fullscreen mode"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.8 15.8L0 13v7h7l-2.8-2.8 4.34-4.32-1.42-1.42L2.8 15.8zM17.2 4.2L20 7V0h-7l2.8 2.8-4.34 4.32 1.42 1.42L17.2 4.2zm-1.4 13L13 20h7v-7l-2.8 2.8-4.32-4.34-1.42 1.42 4.33 4.33zM4.2 2.8L7 0H0v7l2.8-2.8 4.32 4.34 1.42-1.42L4.2 2.8z"/></svg>
              </button>
            </label>
            <label style="margin-left: 10px;">
                <button class="crossbeams-view-row" onclick="crossbeamsGridEvents.viewSelectedRow('#{grid_id}')" title="view selected row"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M.2 10a11 11 0 0 1 19.6 0A11 11 0 0 1 .2 10zm9.8 4a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0-2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg></button>
            </label>#{save_multiselect_button(grid_id, options)}
            <label style="margin-left: 10px;">
                <button class="pure-button" onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{Grid.file_name_from_caption(caption)}')" title="Export to CSV"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 18h12V6h-4V2H4v16zm-2 1V0h12l4 4v16H2v-1z"/></svg>
              </button>
            </label>
            <!-- label style="margin-left: 10px;">
            <button>JMP</button>
            </label -->
            #{print_section}
            <label class="crossbeams-column-jump" style="margin-left: 10px;" hidden>
                <button><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>

                </button>
                <ul id='#{grid_id}-scrollcol' data-grid-id="#{grid_id}" class="crossbeams-column-jump-list"></ul>
            </label>
            <label style="margin-left: 10px;">
                <input class="un-formed-input" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-search="true" data-grid-id="#{grid_id}"/>
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
                                     print_button: false, # This turned off for now
                                     print_url: @url,
                                     multiselect: @multiselect,
                                     multiselect_url: @multiselect_url,
                                     can_be_cleared: @can_be_cleared,
                                     multiselect_save_method: @multiselect_save_method)
          <<~HTML
            <div id="#{@grid_id}-frame" class="grid-frame" style="#{height_style};margin-bottom:4em">#{head_section}
              <div id="#{@grid_id}" style="height:100%;" class="ag-theme-balham" data-gridurl="#{url}" data-grid="grid" #{denote_nested_grid} #{denote_multiselect} #{denote_tree} onload="console.log('onl'); "></div>
            </div>
          HTML
        end

        def self.file_name_from_caption(caption)
          (caption || 'grid_contents').gsub('&nbsp;', 'grid_contents').gsub(%r{[/:*?"\\<>\|\r\n]}i, '-') + '.csv'
        end

        def self.save_multiselect_button(grid_id, options)
          return '' unless options[:multiselect]

          save_method = options[:multiselect_save_method] || 'http'
          <<~HTML
            <label style="margin-left: 10px;">
                <button class="crossbeams-view-savemulti" onclick="crossbeamsGridEvents.saveSelectedRows('#{grid_id}', '#{options[:multiselect_url]}', #{options[:can_be_cleared] == true}, '#{save_method}')" title="save selection"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M0 2C0 .9.9 0 2 0h14l4 4v14a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zm5 0v6h10V2H5zm6 1h3v4h-3V3z"/></svg>
              </button>
            </label>
          HTML
        end

        private

        def height_style
          if @fit_height
            'flex-grow:1'
          else
            "height:#{@height}em"
          end
        end

        def unpack_multiselect_options(options)
          @multiselect = options[:is_multiselect]
          @multiselect_url = options[:multiselect_url]
          @multiselect_key = options[:multiselect_key]
          @multiselect_params = options[:multiselect_params]
          @can_be_cleared = options[:can_be_cleared] || false
          @multiselect_save_method = options[:multiselect_save_method] || 'http'
        end

        def unpack_lookup_options(options)
          @lookup_key = options[:lookup_key]
          @lookup_params = options[:grid_params]
        end

        def url
          return @url if @multiselect.nil? && @query_string.nil? && @lookup_key.nil?
          return "#{@url}?#{@query_string}" unless @query_string.nil?

          if @multiselect
            multiselect_url
          else
            lookup_url
          end
        end

        def multiselect_url
          parms = []
          @multiselect_params.each do |k, v|
            parms << "#{k}=#{v}" unless k == :key
          end
          qstr = parms.empty? ? '' : "?#{parms.join('&')}"
          "#{@url}/#{@multiselect_key}#{qstr}"
        end

        def lookup_url
          parms = []
          @lookup_params.each do |k, v|
            parms << "#{k}=#{v}" unless k == :key
          end
          qstr = parms.empty? ? '' : "?#{parms.join('&')}"
          "#{@url}/#{@id}/#{@lookup_key}#{qstr}"
        end

        def denote_nested_grid
          @nested_grid ? 'data-nested-grid="y"' : ''
        end

        def denote_multiselect
          @multiselect ? "data-grid-multi=\"#{@multiselect_key}\"" : ''
        end

        def denote_tree
          @tree_config ? "data-grid-tree='{\"treeColumn\":\"#{@tree_config[:tree_column]}\",\"treeCaption\":\"#{@tree_config[:tree_caption]}\",\"suppressNodeCounts\":#{@tree_config[:suppress_node_counts]},\"groupDefaultExpanded\":#{@tree_config[:groupDefaultExpanded] || 0}}'" : ''
        end
      end
    end
  end
end
