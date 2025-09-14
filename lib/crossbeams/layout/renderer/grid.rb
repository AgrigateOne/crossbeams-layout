# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Render a Grid
      class Grid < Base # rubocop:disable Metrics/ClassLength
        SC = StylesConfig

        def initialize(grid_id, url, caption, options = {}) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          super()
          @grid_id     = grid_id
          @url         = url
          @caption     = caption
          @nested_grid = options[:nested_grid]
          @query_string = options[:grid_params].nil? ? nil : options[:grid_params][:query_string]
          # Prevent a grid height less than 6em, default to 20.
          @height = [(options[:height] || 20), 6].max
          @fit_height = options[:fit_height] || false
          @tree_config = options[:tree]
          @group_default_expanded = options[:group_default_expanded]
          @colour_key = options[:colour_key]
          @bookmark_row_on_action = options[:grid_params].nil? ? false : options[:grid_params][:bookmark_row_on_action] || false
          @col_defs = options[:col_defs]&.to_json
          @row_defs = options[:row_defs]&.to_json
          @field_update_url = "'#{options[:field_update_url]}'" || 'null'
          @extra_context = (options[:extra_context] || {}).to_json
          @multiselect_ids = options[:multiselect_ids] || 'null'
          @ssrm = options[:ssrm] || false

          unpack_multiselect_options(options)
          unpack_lookup_options(options)
          add_grid_data
        end

        def add_grid_data
          return unless @col_defs

          if @ssrm
            add_dom_loaded(<<~JS)
              crossbeamsGridStaticLoader.loadSSRMGrid('#{@grid_id}', #{@col_defs}, #{@field_update_url}, #{@extra_context});
            JS
            return
          end

          add_dom_loaded(<<~JS)
            crossbeamsGridStaticLoader.loadGrid('#{@grid_id}', #{@col_defs}, #{@row_defs}, #{@field_update_url}, #{@extra_context}, #{@multiselect_ids});
          JS
        end

        def self.tachy_header(grid_id, caption, options = {}) # rubocop:disable Metrics/PerceivedComplexity
          print_section = <<~HTML
            <label style="margin-left: 10px;">
              <button onclick="crossbeamsGridEvents.onBtPrint('#{grid_id}')" title="Print"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 16H0V6h20v10h-4v4H4v-4zm2-4v6h8v-6H6zM4 0h12v5H4V0zM2 8v2h2V8H2zm4 0v2h2V8H6z"/></svg>
              </button>
            </label>
          HTML

          search_box = if @ssrm
                         ''
                       else
                         <<~HTML
                           <label style="margin-left: 10px;">
                               <input class="un-formed-input" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-search="true" data-grid-id="#{grid_id}"/>
                           </label>
                         HTML
                       end

          bookmark_button = if options[:bookmark_row_on_action]
                              <<~HTML
                                <label style="margin-left: 10px;">
                                <button type="button" class="crossbeams-row-bookmark" title="Jump to bookmarked row" hidden>
                                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2z"/></svg>
                                </button>
                                </label>
                              HTML
                            else
                              ''
                            end

          colour_btn = if options[:colour_key]
                         <<~HTML
                           <label style="margin-left: 10px;">
                           <button type="button" class="crossbeams-colour-key">
                             <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9 20v-1.7l.01-.24L15.07 12h2.94c1.1 0 1.99.89 1.99 2v4a2 2 0 0 1-2 2H9zm0-3.34V5.34l2.08-2.07a1.99 1.99 0 0 1 2.82 0l2.83 2.83a2 2 0 0 1 0 2.82L9 16.66zM0 1.99C0 .9.89 0 2 0h4a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zM4 17a1 1 0 1 0 0-2 1 1 0 0 0 0 2z"/></svg>
                           </button>
                           <div class="crossbeams-colour-key-list ba b--light-silver pa1 bg-white">
                           <h3 class="gray">Key for coloured rows</h3>
                           <ul class="list pl0">
                             #{options[:colour_key].map { |k, v| "<li class='#{SC.config.grid_row_colours[k] || k}'>#{v}</li>" }.join}
                           </ul>
                           </div>
                           </label>
                         HTML
                       else
                         ''
                       end

          <<-HTML
          <div class="grid-head">
            <span id="#{grid_id}_toolbtns">
            <label style="margin-left: 10px;">
               <button type="button" class="crossbeams-to-fullscreen" onclick="crossbeamsGridEvents.toFullScreen('#{grid_id}')" title="show in fullscreen mode"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.8 15.8L0 13v7h7l-2.8-2.8 4.34-4.32-1.42-1.42L2.8 15.8zM17.2 4.2L20 7V0h-7l2.8 2.8-4.34 4.32 1.42 1.42L17.2 4.2zm-1.4 13L13 20h7v-7l-2.8 2.8-4.32-4.34-1.42 1.42 4.33 4.33zM4.2 2.8L7 0H0v7l2.8-2.8 4.32 4.34 1.42-1.42L4.2 2.8z"/></svg>
              </button>
            </label>
            <label style="margin-left: 10px;">
                <button type="button" class="crossbeams-view-row" onclick="crossbeamsGridEvents.viewSelectedRow('#{grid_id}')" title="view selected row"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M.2 10a11 11 0 0 1 19.6 0A11 11 0 0 1 .2 10zm9.8 4a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0-2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg></button>
            </label>#{save_multiselect_button(grid_id, options)}
            <label style="margin-left: 10px;">
                <button type="button" class="pure-button" onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{Grid.file_name_from_caption(caption)}')" title="Export to CSV"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 18h12V6h-4V2H4v16zm-2 1V0h12l4 4v16H2v-1z"/></svg>
              </button>
            </label>
            #{bookmark_button}
            #{colour_btn}
            #{print_section}
            <label class="crossbeams-column-jump" style="margin-left: 10px;" hidden>
                <button type="button"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm6 0a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>

                </button>
                <ul id='#{grid_id}-scrollcol' data-grid-id="#{grid_id}" class="crossbeams-column-jump-list"></ul>
            </label>
            <label style="margin-left: 10px;">
                <button type="button" onclick="crossbeamsGridEvents.gridStateSave('#{grid_id}')" title="Save grid column state">
                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M10 3a7 7 0 1 0 .001 13.999A7 7 0 0 0 10 3z" fill="#626262"/></svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateLoad" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateLoad('#{grid_id}')" title="Load previously-saved grid column state">
                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M15 10.001c0 .299-.305.514-.305.514l-8.561 5.303C5.51 16.227 5 15.924 5 15.149V4.852c0-.777.51-1.078 1.135-.67l8.561 5.305c-.001 0 .304.215.304.514z" fill="#626262"/></svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateClear" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateClear('#{grid_id}')" title="Back to default grid column state">
                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M16 4.995v9.808c0 .661-.536 1.197-1.196 1.197H4.997A.997.997 0 0 1 4 15.003V5.196C4 4.536 4.536 4 5.196 4h9.808c.55 0 .996.446.996.995z" fill="#626262"/></svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateDelete" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateDelete('#{grid_id}')" title="Discard saved grid column state">
                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 100 100"><path d="M15.194 59.995l69.732-.074v-.014a2.493 2.493 0 0 0 2.361-2.489a2.487 2.487 0 0 0-.802-1.823L51.834 21.02l-.004.004a2.484 2.484 0 0 0-1.902-.892a2.494 2.494 0 0 0-2.02 1.041l-34.46 34.535a2.498 2.498 0 0 0 1.746 4.287z" fill="#626262"/><path d="M87.308 77.253l-.01-9.803v-.05h-.005a2.534 2.534 0 0 0-2.534-2.485v-.006l-69.751.074v.042a2.53 2.53 0 0 0-2.293 2.516c0 .033.008.063.01.096l.01 9.477c-.006.074-.022.145-.022.22a2.528 2.528 0 0 0 2.311 2.511v.023l69.751-.074a2.536 2.536 0 0 0 2.534-2.539l-.001-.002z" fill="#626262"/></svg>
              </button>
            </label>
            #{search_box}
            </span>
            <span class="grid-caption">
              #{caption}
            </span>
            <span id="#{grid_id}_rowcount" class="crossbeams-rowcount"></span>
          </div>
          HTML
        end

        def self.header(grid_id, caption, options = {}) # rubocop:disable Metrics/PerceivedComplexity
          # Actions
          # - print
          # - export
          # - view?
          # - bookmark?
          # - colour?
          # - fullscreen?
          # - states?

          print_section = <<~HTML
            <button onclick="crossbeamsGridEvents.onBtPrint('#{grid_id}')" class="#{SC.css_class(:button_tertiary)} w-full flex gap-2" title="Print"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 16H0V6h20v10h-4v4H4v-4zm2-4v6h8v-6H6zM4 0h12v5H4V0zM2 8v2h2V8H2zm4 0v2h2V8H6z"/></svg> Print grid
            </button>
          HTML

          bookmark_button = if options[:bookmark_row_on_action]
                              <<~HTML
                                <button type="button" class="crossbeams-row-bookmark #{SC.css_class(:button_tertiary)} w-full flex gap-2" hidden>
                                  <svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2z"/></svg> Jump to bookmarked row
                                </button>
                              HTML
                            else
                              ''
                            end

          actions_button = <<~HTML
            <div class="crossbeams-dropdown-button w-fit relative inline-block">
              <button type="button" class="#{SC.css_class(:button_tertiary)}">
                <svg class="#{SC.css_class(:icon_s)} xcbl-icon " xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"> <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 1 0 0 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186 9.566-5.314m-9.566 7.5 9.566 5.314m0 0a2.25 2.25 0 1 0 3.935 2.186 2.25 2.25 0 0 0-3.935-2.186Zm0-12.814a2.25 2.25 0 1 0 3.933-2.185 2.25 2.25 0 0 0-3.933 2.185Z" /> </svg> Actions
              </button>
              <div class="crossbeams-dropdown-content flex hidden absolute right-0 top-11 z-10 bg-white">
                <button type="button" class="#{SC.css_class(:button_tertiary)} w-full flex gap-2 crossbeams-view-row" onclick="crossbeamsGridEvents.viewSelectedRow('#{grid_id}')"><svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M.2 10a11 11 0 0 1 19.6 0A11 11 0 0 1 .2 10zm9.8 4a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0-2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg> View selected row</button>
                <button type="button" class="#{SC.css_class(:button_tertiary)} w-full flex gap-2 crossbeams-to-fullscreen" onclick="crossbeamsGridEvents.toFullScreen('#{grid_id}-frame')" title="show in fullscreen mode"><svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M2.8 15.8L0 13v7h7l-2.8-2.8 4.34-4.32-1.42-1.42L2.8 15.8zM17.2 4.2L20 7V0h-7l2.8 2.8-4.34 4.32 1.42 1.42L17.2 4.2zm-1.4 13L13 20h7v-7l-2.8 2.8-4.32-4.34-1.42 1.42 4.33 4.33zM4.2 2.8L7 0H0v7l2.8-2.8 4.32 4.34 1.42-1.42L4.2 2.8z"/></svg>
                 Full screen
                </button>
                #{print_section}
                <button type="button" class="#{SC.css_class(:button_tertiary)} w-full flex gap-2 pure-button" onclick="crossbeamsGridEvents.csvExport('#{grid_id}', '#{Grid.file_name_from_caption(caption)}')"><svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M4 18h12V6h-4V2H4v16zm-2 1V0h12l4 4v16H2v-1z"/></svg> Export to CSV
              </button>
              #{bookmark_button}
              </div>
            </div>
          HTML

          # <label class="relative text-gray-400 focus-within:text-gray-600 block">

          # <svg xmlns="http://www.w3.org/2000/svg" class="pointer-events-none w-8 h-8 absolute top-1/2 transform -translate-y-1/2 left-3" viewBox="0 0 20 20" fill="currentColor">
          # <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
          # <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
          # </svg>

          # <input type="email" name="email" id="email" placeholder="email@kemuscorp.com" class="form-input border border-gray-900 py-3 px-4 bg-white placeholder-gray-400 text-gray-500 appearance-none w-full block pl-14 focus:outline-none">
          # </label>
          # search_box = if @ssrm
          #                ''
          #              else
          #                <<~HTML
          #                  <input class="rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 py-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600" onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-search="true" data-grid-id="#{grid_id}"/>
          #                HTML
          #              end
          search_box = if @ssrm
                         ''
                       else
                         <<~HTML
                           <label class="relative inline-block">
                            <svg class="inline stroke-current pointer-events-none w-5 h-5 absolute top-1/2 transform -translate-y-1/2 left-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                              <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
                            </svg>
                           <input class="rounded border border-slate-300 bg-white outline outline-2 outline-transparent outline-offset-2 px-3 pl-10 pr-2 appearance-none text-base leading-6 focus:outline focus:outline-2 focus:outline-transparent focus:outline-offset-2 focus:shadow focus:ring focus:ring-offset-0 focus:border-blue-600 focus-visible:border-blue-600 " onkeyup="crossbeamsGridEvents.quickSearch(event)" placeholder='Search...' data-grid-search="true" data-grid-id="#{grid_id}"/>
                           </label>
                         HTML
                       end

          colour_btn = if options[:colour_key]
                         <<~HTML
                           <label style="margin-left: 10px;">
                           <button type="button" class="crossbeams-colour-key #{SC.css_class(:button_tertiary)}">
                             <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9 20v-1.7l.01-.24L15.07 12h2.94c1.1 0 1.99.89 1.99 2v4a2 2 0 0 1-2 2H9zm0-3.34V5.34l2.08-2.07a1.99 1.99 0 0 1 2.82 0l2.83 2.83a2 2 0 0 1 0 2.82L9 16.66zM0 1.99C0 .9.89 0 2 0h4a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zM4 17a1 1 0 1 0 0-2 1 1 0 0 0 0 2z"/></svg>
                           </button>
                           <div class="crossbeams-colour-key-list border border:bg-slate-400 p-1 bg-white">
                           <h3 class="#{SC.css_class(:h3)}">Key for coloured rows</h3>
                           <ul class="list pl0">
                             #{options[:colour_key].map { |k, v| "<li class='#{SC.config.grid_row_colours[k] || k}'>#{v}</li>" }.join}
                           </ul>
                           </div>
                           </label>
                         HTML
                       else
                         ''
                       end
          #colour_list = if options[:colour_key]
          #                <<~HTML
          #                  <ul class="flex space-x-4">
          #                    #{options[:colour_key].map { |k, v| "<li class='#{SC.config.grid_row_colours[k] || k}'>#{v}</li>" }.join}
          #                  </ul>
          #                HTML
          #              else
          #                ''
          #              end

          # TRASH
          # <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
          #   <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
          # </svg>
          #
          # ARROW-PATH
          # <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
          #   <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99" />
          # </svg>

          #
          # SWATCH
          # <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
          #   <path stroke-linecap="round" stroke-linejoin="round" d="M4.098 19.902a3.75 3.75 0 0 0 5.304 0l6.401-6.402M6.75 21A3.75 3.75 0 0 1 3 17.25V4.125C3 3.504 3.504 3 4.125 3h5.25c.621 0 1.125.504 1.125 1.125v4.072M6.75 21a3.75 3.75 0 0 0 3.75-3.75V8.197M6.75 21h13.125c.621 0 1.125-.504 1.125-1.125v-5.25c0-.621-.504-1.125-1.125-1.125h-4.072M10.5 8.197l2.88-2.88c.438-.439 1.15-.439 1.59 0l3.712 3.713c.44.44.44 1.152 0 1.59l-2.879 2.88M6.75 17.25h.008v.008H6.75v-.008Z" />
          # </svg>


          <<-HTML
          <div id="#{grid_id}_toolbtns" class="flex justify-between flex-row pt-3 pb-3">
            <div class="flex gap-4 pt-2 h-fit">
            #{search_box}
            <span class="grid-caption">
              #{caption}
            </span>
            </div>

            <div class="inline-block">
            #{save_multiselect_button(grid_id, options)}
            #{colour_btn}
            #{actions_button}
            <label style="margin-left: 10px;">
                <button type="button" class="#{SC.css_class(:button_tertiary)}" onclick="crossbeamsGridEvents.gridStateSave('#{grid_id}')" title="Save grid column state">
                  <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M10 3a7 7 0 1 0 .001 13.999A7 7 0 0 0 10 3z" fill="#626262"/></svg> Save columns
              <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
              </svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateLoad" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateLoad('#{grid_id}')" title="Load previously-saved grid column state">
                  <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M15 10.001c0 .299-.305.514-.305.514l-8.561 5.303C5.51 16.227 5 15.924 5 15.149V4.852c0-.777.51-1.078 1.135-.67l8.561 5.305c-.001 0 .304.215.304.514z" fill="#626262"/></svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateClear" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateClear('#{grid_id}')" title="Back to default grid column state">
                  <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 20 20"><path d="M16 4.995v9.808c0 .661-.536 1.197-1.196 1.197H4.997A.997.997 0 0 1 4 15.003V5.196C4 4.536 4.536 4 5.196 4h9.808c.55 0 .996.446.996.995z" fill="#626262"/></svg>
              </button>
            </label>
            <label style="margin-left: 0px;" class="gridStateDelete" hidden>
                <button type="button" onclick="crossbeamsGridEvents.gridStateDelete('#{grid_id}')" title="Discard saved grid column state">
                  <svg class="#{SC.css_class(:icon_s)}" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" focusable="false" width="1em" height="1em" style="-ms-transform: rotate(360deg); -webkit-transform: rotate(360deg); transform: rotate(360deg);" preserveAspectRatio="xMidYMid meet" viewBox="0 0 100 100"><path d="M15.194 59.995l69.732-.074v-.014a2.493 2.493 0 0 0 2.361-2.489a2.487 2.487 0 0 0-.802-1.823L51.834 21.02l-.004.004a2.484 2.484 0 0 0-1.902-.892a2.494 2.494 0 0 0-2.02 1.041l-34.46 34.535a2.498 2.498 0 0 0 1.746 4.287z" fill="#626262"/><path d="M87.308 77.253l-.01-9.803v-.05h-.005a2.534 2.534 0 0 0-2.534-2.485v-.006l-69.751.074v.042a2.53 2.53 0 0 0-2.293 2.516c0 .033.008.063.01.096l.01 9.477c-.006.074-.022.145-.022.22a2.528 2.528 0 0 0 2.311 2.511v.023l69.751-.074a2.536 2.536 0 0 0 2.534-2.539l-.001-.002z" fill="#626262"/></svg>
              </button>
            </label>
            </div>
          </div>
          HTML
          # <span id="#{grid_id}_rowcount" class="crossbeams-rowcount"></span>
        end

        def render
          head_section = Grid.header(@grid_id, @caption,
                                     print_button: false, # This turned off for now
                                     print_url: @url,
                                     multiselect: @multiselect,
                                     multiselect_url: @multiselect_url,
                                     can_be_cleared: @can_be_cleared,
                                     multiselect_save_method: @multiselect_save_method,
                                     bookmark_row_on_action: @bookmark_row_on_action,
                                     colour_key: @colour_key)
          <<~HTML
            <div id="#{@grid_id}-frame" class="grid-frame" style="#{height_style};margin-bottom:4em">#{head_section}
              <div id="#{@grid_id}" style="height:100%;" class="ag-theme-balham" data-gridurl="#{url}" data-grid="grid" #{denote_nested_grid} #{denote_multiselect} #{denote_group_expanded} #{denote_tree} #{denote_ssrm}></div>
            </div>
          HTML
        end

        def self.file_name_from_caption(caption)
          "#{(caption || 'grid_contents').gsub('&nbsp;', 'grid_contents').gsub(%r{[/:*?"\\<>\|\r\n]}i, '-')}.csv"
        end

        def self.save_multiselect_button(grid_id, options)
          return '' unless options[:multiselect]

          save_method = options[:multiselect_save_method] || 'http'
          <<~HTML
            <label style="margin-left: 10px;">
                <button class="#{SC.css_class(:button_primary)} crossbeams-view-savemulti" onclick="crossbeamsGridEvents.saveSelectedRows('#{grid_id}', '#{options[:multiselect_url]}', #{options[:can_be_cleared] == true}, '#{save_method}')" title="save selection"><svg class="cbl-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M0 2C0 .9.9 0 2 0h14l4 4v14a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2zm5 0v6h10V2H5zm6 1h3v4h-3V3z"/></svg> Save selection
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
          if @multiselect
            @multiselect_key = 'ms' if @multiselect_key.nil?
            @multiselect_params = {} if @multiselect_params.nil?
          end
          @can_be_cleared = options[:can_be_cleared] || false
          @multiselect_save_method = options[:multiselect_save_method] || 'http'
        end

        def unpack_lookup_options(options)
          @lookup_key = options[:lookup_key]
          @lookup_params = options[:grid_params]
        end

        def url
          return @url if @col_defs
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

        def denote_group_expanded
          return '' unless @group_default_expanded

          raise Error, 'Group cannot expand a negative amount. Use -1 for all, 0 for none or a positive number for a specific amount.' if @group_default_expanded.to_i < -1

          %(data-group-expanded-state=\"#{@group_default_expanded}\")
        end

        def denote_tree
          @tree_config ? "data-grid-tree='{\"treeColumn\":\"#{@tree_config[:tree_column]}\",\"treeCaption\":\"#{@tree_config[:tree_caption]}\",\"suppressNodeCounts\":#{@tree_config[:suppress_node_counts]},\"groupDefaultExpanded\":#{@tree_config[:groupDefaultExpanded] || 0}}'" : ''
        end

        def denote_ssrm
          return '' unless @ssrm

          'data-grid-row-model="server"'
        end
      end
    end
  end
end
