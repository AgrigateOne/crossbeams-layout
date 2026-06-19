# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/BlockLength
module Crossbeams
  module Layout
    # Generate HTML examples
    class ExamplesGenerator
      attr_reader :classes, :style

      SCC = StylesConfig.config
      SC = StylesConfig

      def initialize(classes = :all, style: :tc)
        @classes = classes
        @style = style
      end

      def generate_content # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        @out = []
        build_contents
        @out << generate_help_link if %i[all help_link].include? classes
        @out << generate_link if %i[all link].include? classes
        @out << generate_dropdown_button if %i[all dropdown_button].include? classes
        @out << generate_icons if %i[all icon].include? classes
        @out << generate_text if %i[all text].include? classes
        @out << generate_form if %i[all form].include? classes
        @out << generate_sections if %i[all section].include? classes
        @out << generate_collections if %i[all collection].include? classes
        @out << generate_tables if %i[all table].include? classes
        @out << generate_progress_step if %i[all progress_step].include? classes
        @out << generate_list if %i[all list].include? classes
        @out << generate_sortable_list if %i[all sortable_list].include? classes
        @out << generate_row if %i[all row].include? classes
        @out << generate_notice if %i[all notice].include? classes
        @out << generate_foldup if %i[all foldup].include? classes
        @out << generate_address if %i[all address].include? classes
        @out << generate_contact_method if %i[all contact_method].include? classes
        @out << generate_grid if %i[all grid].include? classes
        @out << generate_diff if %i[all diff].include? classes
        @out << generate_tab_set if %i[all tab_set].include? classes
        @out << generate_miscellaneous if %i[all generate_miscellaneous].include? classes
        @out << generate_loading_message if %i[all loading_message].include? classes
        @out << generate_repeating_request if %i[all repeating_request].include? classes
        @out << generate_callback_section if %i[all callback_section].include? classes
        @out << generate_dashboard if %i[all dashboard].include? classes
        @out << generate_colours if %i[all colours].include? classes
        @out << generate_layout_grid if %i[all layout_grid].include? classes
        @out << generate_download_dashboard_button if %i[all download_dashboard_button].include? classes
        @out << generate_filter if %i[all filter].include? classes
        @out << generate_no_data if %i[all no_data].include? classes
        @out
      end

      private

      def add_class(key)
        return '' if style == :tc

        %( class="#{SCC.send(key)}")
      end

      def build_contents # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        @out << %(<h2#{add_class(:h2)}>Contents</h2><ol#{add_class(:ol)}>)
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#help_link">Help link</a></li>) if %i[all help_link].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#link">Link (and as buttons)</a></li>) if %i[all link].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#dropdown_button">Dropdown Button</a></li>) if %i[all dropdown_button].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#icons">Icons</a></li>) if %i[all icon].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#text">Text</a></li>) if %i[all text].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#form">Form</a></li>) if %i[all form].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#sections">Sections</a></li>) if %i[all section].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#collections">Collections</a></li>) if %i[all collection].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#tables">Tables</a></li>) if %i[all table].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#progress_step">Progress Step</a></li>) if %i[all progress_step].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#list">List</a></li>) if %i[all list].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#sortable_list">Sortable List</a></li>) if %i[all sortable_list].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#row">Rows and Cols</a></li>) if %i[all row].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#notice">Notice</a></li>) if %i[all notice].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#foldup">Foldup</a></li>) if %i[all foldup].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#address">Address</a></li>) if %i[all address].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#contact_method">Contact</a></li>) if %i[all contact_method].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#grid">Grid</a></li>) if %i[all grid].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#diff">Diff</a></li>) if %i[all diff].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#tab_set">Tab Set</a></li>) if %i[all tab_set].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#miscellaneous">Miscellaneous styling</a></li>) if %i[all miscellaneous].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#loading_message">Loading Mesage</a></li>) if %i[all loading_message].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#repeating_request">Repeating Request</a></li>) if %i[all repeating_request].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#callback_section">Callback Section</a></li>) if %i[all callback_section].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#dashboard">Dashboard</a></li>) if %i[all dashboard].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#colours">Colours</a></li>) if %i[all colours].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#layout_grid">LayoutGrid</a></li>) if %i[all layout_grid].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#download_dashboard_button">DownloadDashboardButton</a></li>) if %i[all download_dashboard_button].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#filter">Filter</a></li>) if %i[all filter].include? classes
        @out << %(<li#{add_class(:li)}><a#{add_class(:link)} href="#no_data">No Data</a></li>) if %i[all no_data].include? classes
        @out << '</ol>'
      end

      def head(caption, anchor)
        %(<div class="#{style == :tc ? 'tc b pv2 bt bl br mt4' : 'text-center font-bold py-2 bg-ocean-200 mt-8'}"><a name="#{anchor}">#{caption}</a></div>)
      end

      def separator
        %(<hr class="#{style == :tc ? 'mt1 blue' : 'mt-4 mb-2 text-blue-500'}">)
      end

      def generate_icons
        ar = [head('Icons', 'icons')]
        if style == :tc
          ar << '<table class="table-collapse"><thead><tr><th>Name</th><th class="br">Icon</th><th>Name</th><th class="br">Icon</th><th>Name</th><th class="br">Icon</th><th>Name</th><th>Icon</th></tr></thead><tbody>'
          # ar += Icon.available_icons.map { |i| %(<tr><td class="pa2">#{i}</td><td class="pa2">#{Icon.render(i)}</td></tr>) }
          Icon.available_icons.each_slice(4) { |i1, i2, i3, i4| ar << %(<tr><td class="pa2">#{i1}</td><td class="br pa2">#{Icon.render(i1)}</td><td class="pa2">#{i2}</td><td class="br pa2">#{Icon.render(i2)}</td><td class="pa2">#{i3}</td><td class="br pa2">#{Icon.render(i3)}</td><td class="pa2">#{i4}</td><td class="pa2">#{Icon.render(i4)}</td></tr>) }
        else
          ar << '<table class="border-collapse"><thead><tr><th>Name</th><th class="border-r">Icon</th><th>Name</th><th class="border-r">Icon</th><th>Name</th><th class="border-r">Icon</th><th>Name</th><th>Icon</th></tr></thead><tbody>'
          Icon.available_icons.each_slice(4) { |i1, i2, i3, i4| ar << %(<tr><td class="p-2">#{i1}</td><td class="border-r p-2">#{Icon.render(i1)}</td><td class="p-2">#{i2}</td><td class="border-r p-2">#{Icon.render(i2)}</td><td class="p-2">#{i3}</td><td class="border-r p-2">#{Icon.render(i3)}</td><td class="p-2">#{i4}</td><td class="p-2">#{Icon.render(i4)}</td></tr>) }
        end
        ar << '</tbody></table>'
        ar.join("\n")
      end

      def generate_collections
        ar = [head('Collections', 'collections')]
        collection = Collection.new
        9.times do |n|
          collection.add_control control_type: :link,
                                 text: "Control button #{n + 1}",
                                 url: '/'
        end
        ar << collection.render

        collection = Collection.new
        collection.add_list %w[one two three four five six seven eight nine ninehundred-ninety-nine]
        ar << collection.render

        ar.join(separator)
      end

      def generate_sections
        ar = [head('Sections', 'sections')]
        section = Section.new({}, 1)
        section.add_text 'Default section'
        ar << section.render
        section = Section.new({}, 2)
        section.show_border!
        section.add_text 'Section with border'
        ar << section.render
        section = Section.new({}, 3)
        section.add_caption 'With caption'
        section.dom_id 'dom_replaced_id'
        section.add_text 'Section with caption and DOM id'
        ar << section.render
        section = Section.new({}, 4)
        section.fit_height!
        section.add_text 'Fit height section'
        ar << section.render
        section = Section.new({}, 5)
        section.full_dialog_height!
        section.add_text 'Full Dialog height section'
        ar << section.render
        section = Section.new({}, 6)
        section.half_dialog_height!
        section.add_text 'Half Dialog height section'
        ar << section.render

        section = Section.new({}, 7)
        section.add_text 'Section with horizontal group showing button'
        section.horizontal_group do |grp|
          grp.add_text 'Group'
          grp.add_control control_type: :link, text: 'A Button', url: '/', style: :button
        end
        ar << section.render
        section = Section.new({}, 8)
        section.add_text 'Section with horizontal group showing button and caption'
        section.horizontal_group do |grp|
          grp.add_caption 'Caption'
          grp.add_text 'Group'
          grp.add_control control_type: :link, text: 'A Button', url: '/', style: :button
        end
        ar << section.render
        ar.join(separator)
      end

      def generate_tables
        ar = [head('Tables', 'tables')]
        rows = [{ col1: 'r1, content 1', col2: 'r1, content 2' }, { col1: 'r2, content 1', col2: 'r2, content 2' }]
        cols = %i[col1 col2]
        tab = Table.new({}, rows, cols)
        ar << tab.render
        rows.first[:col1] = 'PIVOT r1, content 1'
        tab = Table.new({}, rows, cols, pivot: true)
        ar << tab.render
        rows.first[:col1] = 'TopMargin r1, content 1'
        tab = Table.new({}, rows, cols, top_margin: 3)
        ar << tab.render
        rows.first[:col1] = 'LeftMargin r1, content 1'
        tab = Table.new({}, rows, cols, left_margin: 3)
        ar << tab.render
        rows.first[:col1] = 'r1, content 1'
        tab = Table.new({}, rows, cols, caption: 'with caption and DOM id', dom_id: 'eg-table')
        ar << tab.render
        ar.join(separator)
      end

      def generate_text
        ar = [head('Text', 'text')]
        txt = Text.new({}, 'Default text')
        ar << txt.render
        Text::WRAP_START.each_key do |wrap|
          txt = Text.new({}, "Text wrapped with #{wrap}", wrapper: wrap)
          ar << txt.render
        end
        txt = Text.new({}, 'Preformatted text', preformatted: true)
        ar << txt.render
        txt = Text.new({}, "class Ruby\n  def text\n    puts 'syntax: :ruby'\n  end\nend", syntax: :ruby)
        ar << txt.render
        txt = Text.new({}, "SELECT *, 'sql' AS syntax FROM users", syntax: :sql)
        ar << txt.render
        txt = Text.new({}, 'Text with a wrapper class', wrapper: :h2, wrapper_classes: 'mb0')
        ar << txt.render
        txt = Text.new({}, 'Text to toggle an element <p id="toggler">show or hide me</p>', toggle_button: true, toggle_element_id: 'toggler')
        ar << txt.render
        ar.join(separator)
      end

      def generate_progress_step
        ar = [head('ProgressStep', 'progress_step')]
        step = ProgressStep.new({}, %w[Step1])
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3])
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3], position: 1)
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3], position: 2, show_finished: true)
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3], position: 2, size: :small)
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3], position: 2, size: :medium)
        ar << step.render
        step = ProgressStep.new({}, %w[Step1 Step2 Step3], position: 1, state_description: %w[Description1 Description Description3])
        ar << step.render
        ar.join(separator)
      end

      def generate_list
        ar = [head('List', 'list')]
        lst = List.new({}, %w[One Two Three])
        ar << lst.render
        lst = List.new({}, [%w[One 1], %w[Two 2], %w[Three 3]], remove_item_url: '/a/path/$:id$')
        ar << lst.render
        lst = List.new({}, %w[One Two Three], scroll_height: :short, filled_background: true)
        ar << lst.render
        lst = List.new({}, %w[One Two Three], scroll_height: :medium, filled_background: true)
        ar << lst.render
        lst = List.new({}, %w[One Two Three], caption: 'List caption')
        ar << lst.render
        ar.join(separator)
      end

      def generate_link
        ar = [head('Link', 'link')]
        lnk = Link.new(text: 'Clickme', url: '/a/path', title: 'A title')
        ar << lnk.render
        [1, 2, 3, 4, 5, 6].each do |size|
          lnk = Link.new(text: "Clickme (#{size})", url: '/a/path', style: :button, text_size: size)
          ar << lnk.render
        end
        %i[standard button small_button back_button action_button].each do |style|
          lnk = Link.new(text: "Clickme (#{style})", url: '/a/path', style: style)
          ar << lnk.render
        end
        %i[standard red green amber blue].each do |colour|
          lnk = Link.new(text: "Clickme (#{colour}", url: '/a/path', style: :button, button_colour: colour)
          ar << lnk.render
        end
        lnk = Link.new(text: 'InVisible (YOU SHOULD NOT SEE ME)', url: '/a/path', style: :button, visible: false)
        ar << lnk.render
        ar.join(separator)
      end

      def generate_row
        ar = [head('Row + Col', 'row')]
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'col1', css_classes: style == :tc ? 'bg-orange' : 'bg-orange-200 p-2'
        end
        row.column do |col|
          col.add_text 'col2', css_classes: style == :tc ? 'bg-green' : 'bg-blue-200 p-2'
        end
        ar << row.render
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'one-sided col (with blank)', css_classes: style == :tc ? 'bg-orange' : 'bg-orange-200 p-2'
        end
        row.blank_column
        ar << row.render
        row = Row.new({}, 1, 1)
        row.blank_column
        row.column do |col|
          col.add_text 'other-sided col (with blank)', css_classes: style == :tc ? 'bg-green' : 'bg-blue-200 p-2'
        end
        ar << row.render
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'col1 full width', css_classes: style == :tc ? 'bg-orange' : 'bg-orange-200 p-2'
        end
        row.column do |col|
          col.add_text 'col2 full width', css_classes: style == :tc ? 'bg-green' : 'bg-blue-200 p-2'
        end
        row.fit_width!
        ar << row.render
        ar.join(separator)
      end

      def generate_notice
        ar = [head('Notice', 'notice')]
        ntc = Notice.new({}, 'Default notice text')
        ar << ntc.render
        ntc = Notice.new({}, 'Notice without caption', show_caption: false)
        ar << ntc.render
        ntc = Notice.new({}, 'Successs Notice', notice_type: :success)
        ar << ntc.render
        ntc = Notice.new({}, 'Warning Notice', notice_type: :warning)
        ar << ntc.render
        ntc = Notice.new({}, 'Error Notice', notice_type: :error)
        ar << ntc.render
        ntc = Notice.new({}, 'Notice outside a crossbeams field', within_field: false)
        ar << ntc.render
        ar.join(separator)
      end

      def generate_foldup
        ar = [head('FoldUp', 'foldup')]
        fld = FoldUp.new({}, 1)
        fld.add_text 'Default fold'
        ar << fld.render
        fld = FoldUp.new({}, 1)
        fld.add_text 'Fold rendered initially-open'
        fld.caption 'Non-default caption'
        fld.open!
        ar << fld.render

        aa = ['<div id="frm1">']
        aa << ExpandCollapseFolds.new({}, 1, parent_dom_id: 'frm1').render
        fld = FoldUp.new({}, 1)
        fld.add_text 'Fold with expand/collapse'
        aa << fld.render
        aa << '</div>'
        ar << aa.join("\n")

        aa = ['<div id="frm2">']
        aa << ExpandCollapseFolds.new({}, 1, parent_dom_id: 'frm2', button: true).render
        fld = FoldUp.new({}, 1)
        fld.add_text 'Fold with Button expand/collapse'
        aa << fld.render
        aa << '</div>'
        ar << aa.join("\n")

        aa = ['<div id="frm3">']
        aa << ExpandCollapseFolds.new({}, 1, parent_dom_id: 'frm3', button: true, mini: true).render
        fld = FoldUp.new({}, 1)
        fld.add_text 'Fold with mini button expand/collapse'
        aa << fld.render
        aa << '</div>'
        ar << aa.join("\n")

        ar.join(separator)
      end

      def generate_address
        ad = [{ address_type: 'Postal', address_line_1: 'Addr1 (includes address type)', address_line_2: 'Addr2', address_line_3: 'Addr3', city: 'City', postal_code: '1234', country: 'Cntry' }] # rubocop:disable Naming/VariableNumber
        ar = [head('Address', 'address')]
        add = Address.new({}, ad)
        ar << add.render
        add = Address.new({}, ad.map { |a| a.merge(address_line_1: 'Addr1') }, include_address_type: false) # rubocop:disable Naming/VariableNumber
        ar << add.render
        ar.join(separator)
      end

      def generate_contact_method
        ad = [OpenStruct.new({ contact_method_type: 'tel', contact_method_code: '123' }), OpenStruct.new({ contact_method_type: 'cell', contact_method_code: '456' })]
        ar = [head('Contact Method', 'contact_method')]
        cnt = ContactMethod.new({}, ad)
        ar << cnt.render
        ar.join(separator)
      end

      def generate_grid
        ar = [head('Grid Header', 'grid')]
        gridid = 'gridid0'
        grd = Grid.new({}, gridid, '/example_controls_grid')
        ar << grd.render
        gridid = gridid.succ
        grd = Grid.new({}, gridid, '/example_controls_grid', caption: 'Grid Caption, height, colour key, bkmark', height: 10, colour_key: { red: 'Danger', green: 'OK' }, bookmark_row_on_action: true)
        ar << grd.render
        # fit_height
        ar.join(separator)
      end

      def generate_dropdown_button
        ar = [head('Dropdown Button', 'dropdown_button')]
        btn = DropdownButton.new(text: 'Drop button', items: [{ url: '/a/path', text: 'Link1 std' }, { url: '/a/path', text: 'Link2 loading window', loading_window: true }, { url: '/a/path', text: 'Link3 popup', behaviour: :popup }])
        ar << btn.render
        btn = DropdownButton.new(text: 'Back button', items: [{ url: '/a/path', text: 'Link1' }, { url: '/a/path', text: 'Link2' }, { url: '/a/path', text: 'Link3' }], style: :back_button)
        ar << btn.render
        ar.join(separator)
      end

      def generate_download_dashboard_button
        ar = [head('Download Dashboard Button', 'download_dashboard_button')]
        btn = DownloadDashboardButton.new
        ar << btn.render
        btn = DownloadDashboardButton.new(text: 'Download Me', title: 'A title', tabset_id: 'dom_tabset_id', filter_id: 'dom_filter_id')
        ar << btn.render
        ar.join(separator)
      end

      def generate_filter
        ar = [head('Filter', 'filter')]
        filter = Filter.new
        filter.url '/'
        filter.target_dom_id 'aaa'
        filter.add_filter(:a_field, items: %w[One Two Three])
        ar << filter.render
        filter = Filter.new
        filter.url '/'
        filter.target_dom_id 'bbb'
        filter.add_filter(:b_field, items: %w[One Two Three], selected: 'Two')
        ar << filter.render
        ar.join(separator)
      end

      def generate_no_data
        ar = [head('NoData', 'no_data')]
        no_data = NoData.new
        ar << no_data.render
        no_data = NoData.new(msg: 'A different message for no data', sub_msg: '...with a sub-message')
        ar << no_data.render
        ar.join(separator)
      end

      def generate_diff
        ar = [head('Diff', 'diff')]
        rules = OpenStruct.new(options: { fields: { diffkey: { left: "aaaa\nbbbbbb\ncccccc\nddd\neeeeeeeee", right: "aaaaa\nbbbbbb\nddd\ncccccc\neeeeeeeee" } } })
        dif = Diff.new(rules, :diffkey)
        ar << dif.render
        ar.join(separator)
      end

      def generate_help_link
        ar = [head('Help Link', 'help_link')]
        hlp = HelpLink.new(text: 'Help1', path: %i[path to help], dialog: true)
        ar << hlp.render
        hlp = HelpLink.new(text: 'Help2 (lift: 2)', path: %i[path to help], lift: 2)
        ar << hlp.render
        ar << '<p>This text acts as a spacer so the (position:absolute) help links render reasonably ==&gt;</p>'
        ar.join("\n")
      end

      def generate_sortable_list
        ar = [head('Sortable List', 'sortable_list')]
        page_config = OpenStruct.new(name: 'crossbeams')
        srt = SortableList.new(page_config, 'aaa', [['one', 1], ['two', 2], ['three', 3]])
        ar << srt.render
        srt = SortableList.new(page_config, 'bbb', [['one', 1], ['two', 2], ['three', 3]], caption: 'Sortable List with Caption')
        ar << srt.render
        ar.join(separator)
      end

      def generate_loading_message
        ar = [head('Loading Message', 'loading_message')]
        msg = LoadingMessage.new
        ar << msg.render
        msg = LoadingMessage.new(caption: 'Loading caption')
        ar << msg.render
        ar.join(separator)
      end

      def generate_repeating_request
        ar = [head('Repeating Request', 'repeating_request')]
        rpt = RepeatingRequest.new({}, '/nonexistent/path/for/repeatingrequest', 500, '<p>There is a repeating request here set to 500...</p>')
        ar << rpt.render
        ar.join(separator)
      end

      def generate_callback_section
        ar = [head('Callback Section', 'callback_section')]
        sec = CallbackSection.new({}, 1)
        sec.caption_text 'A Callback section...'
        sec.callback_url '/nonexistent/path/for/callback'
        ar << sec.render
        ar.join(separator)
      end

      def generate_miscellaneous
        ar = [head('Miscellaneous', 'miscellaneous')]
        [[:bg_green, 'GREEN'], [:bg_amber, 'AMBER'], [:bg_red, 'RED'], [:bg_blue, 'BLUE']].each do |key, name|
          ar << %(<p>Background colour :#{key} <span class="px-2 py-2 #{SC.css_class(key)}">#{name}</span></p>)
        end
        ar << %(<p>Boolean display :show_check_on <span class="px-2 py-2 #{SC.css_class(:show_check_on)}">#{Icon.render(:checkon)}</span></p>)
        ar << %(<p>Boolean display :show_check_off <span class="px-2 py-2 #{SC.css_class(:show_check_off)}">#{Icon.render(:checkoff)}</span></p>)
        ar.join('<br>')
      end

      # multipart
      def generate_form
        ar = [head('Form', 'form')]
        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: nil), fields: { inp1: {} } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm1'
        frm.caption ' Form Caption'
        frm.add_field :inp1
        ar << frm.render

        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: 'value', sel2: 'four', lbl1: 'Label 1', msl1: %w[one three]),
                                       fields: { inp1: { caption: 'INP One' },
                                                 inp2: { required: true, caption: 'INP Two has a longer caption than normal' },
                                                 inp3: { copy_to_clipboard: true, caption: 'INP Three (copy to clipboard)' },
                                                 inp4: { force_uppercase: true, caption: 'INP Four (force uppercase)' },
                                                 inp5: { renderer: :file, caption: 'INP Five (Upload a file)' },
                                                 dat1: { renderer: :date },
                                                 dat2: { renderer: :datetime, required: true, hint: Utils.classify_dom_elements('<h3>A hint</h3>For a datetime') },
                                                 chk1: { renderer: :checkbox },
                                                 # chk2: { renderer: :checkbox, required: true, hint: Utils.classify_dom_elements('<h3>A hint</h3>For a checkbox') },
                                                 chk2: { renderer: :checkbox, required: true, hint: '<h3>A hint</h3>For a checkbox', tooltip: 'A tooltip here...' },
                                                 num1: { renderer: :integer, caption: 'Integer' },
                                                 num2: { renderer: :number, caption: 'Decimal', required: true },
                                                 mlt1: { renderer: :multi, options: %w[one two three four], required: true },
                                                 msl1: { renderer: :select_multiple, options: %w[one two three four], required: true, sort_items: false },
                                                 msl2: { renderer: :select_multiple, options: { 'Group1' => [['one', 1], ['two', 2]],
                                                                                                'Group2' => [['three', 3], ['four', 4]] }, sort_items: false },
                                                 rdo1: { renderer: :radio_group, required: true, options: [['Opt one', 'opt_one'], ['Opt two', 'opt_two']] },
                                                 txt1: { renderer: :textarea, required: true },
                                                 lst1: { renderer: :list, items: %w[one two three], required: true },
                                                 lst2: { renderer: :list, items: [['One', 1], ['Two', 2], ['Three', 3]], filled_background: true, remove_item_url: '/a/path/$:id$/remove' },
                                                 lkp1: { renderer: :lookup,
                                                         lookup_name: 'a_query',
                                                         lookup_key: 'a_key' },
                                                 lkp2: { renderer: :lookup,
                                                         caption: 'Lkp with long caption field',
                                                         lookup_name: 'a_query',
                                                         lookup_key: 'a_key',
                                                         show_field: :fred,
                                                         required: true },
                                                 lbl1: { renderer: :label },
                                                 lbl2: { renderer: :label, with_value: 'A label' },
                                                 sel1: { renderer: :select, options: %w[one two three four five six seven eight nine ten eleven], disabled_options: %w[four], prompt: 'Select something', min_charwidth: 20 },
                                                 sel2: { renderer: :select, options: %w[one two three], disabled_options: %w[four], prompt: 'Select something', required: true } } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm2'
        frm.row do |row|
          row.column do |col|
            col.add_field :inp1
            col.add_field :sel1
            col.add_field :dat1
            col.add_field :num1
            col.add_field :chk1
            col.add_field :lbl1
            col.add_field :msl1
            col.add_field :lkp1
            col.add_field :lst1
          end
          row.column do |col|
            col.add_field :inp2
            col.add_field :sel2
            col.add_field :dat2
            col.add_field :num2
            col.add_field :chk2
            col.add_field :lbl2
            col.add_field :msl2
            col.add_field :lkp2
            col.add_field :lst2
          end
        end
        frm.row do |row|
          row.column do |col|
            col.add_field :inp3
            col.add_field :inp4
            col.add_field :inp5
            col.add_field :mlt1
            col.add_field :rdo1
            col.add_field :txt1
          end
        end
        frm.add_button 'Blue action', '/', colour: :blue
        frm.add_button 'Green action', '/', colour: :green
        frm.add_button 'Amber action', '/', colour: :amber
        frm.add_button 'Red action', '/', colour: :red
        frm.add_button 'Std action', '/'

        ar << frm.render

        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: nil), fields: { inp1: { caption: 'INP Inline', placeholder: 'Like for search' } } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm3'
        frm.inline!
        frm.submit_captions 'Inline'
        frm.add_field :inp1
        ar << frm.render

        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: 'view-only value'), fields: { inp1: { renderer: :label, caption: 'INP view' } } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm4'
        frm.view_only!
        frm.add_field :inp1
        ar << frm.render

        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: 'value'),
                                       fields: { inp1: {},
                                                 inp2: { required: true },
                                                 inp3: { renderer: :textarea },
                                                 inp4: { renderer: :checkbox },
                                                 inp5: { renderer: :datetime },
                                                 inp6: { renderer: :select_multiple, options: %w[a b c d] },
                                                 inp7: { renderer: :select, options: %w[a b c d] },
                                                 inp8: { renderer: :radio_group, options: [%w[a b], %w[c d]] },
                                                 inp9: { renderer: :multi, options: %w[a b c d] } },
                                       form_errors: { base: ['A base validation error'],
                                                      inp2: ['value is incorrect'],
                                                      inp3: ['value is incorrect'],
                                                      inp4: ['value is incorrect'],
                                                      inp5: ['value is incorrect'],
                                                      inp6: ['value is incorrect'],
                                                      inp7: ['value is incorrect'],
                                                      inp8: ['value is incorrect'],
                                                      inp9: ['value is incorrect'] } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm-err'
        frm.caption ' Form With Errors'
        frm.add_field :inp1
        frm.add_field :inp2
        frm.add_field :inp3
        frm.add_field :inp4
        frm.add_field :inp5
        frm.add_field :inp6
        frm.add_field :inp7
        frm.add_field :inp8
        frm.add_field :inp9
        ar << frm.render

        ar.join(separator)
      end

      # FORM + FORM-BUTTON + FIELDS

      def generate_dashboard
        ar = [head('Dashboard', 'dashboard')]
        dash = Dashboard.new(caption: 'Example Dashboard')
        dash.add_sub_caption 'A sub-caption...'

        dash.lane do |lane|
          lane.caption 'Lane caption'
          lane.item_set do |items|
            items.max_width 500

            items.item do |item|
              item.header 'Plain head'
              item.add_percentage 60
              item.add_label_val_array [['Array', 1], ['of', 2], ['elements', 3]]
              item.add_label_val_array [['Array', 1], ['of', 2], ['gray elements', 3]], bg: :gray
              item.add_label_val_array [['Array', 1], ['of', 2], ['blue elements', 3]], bg: :blue
              item.add_label_val_array [['Array', 1], ['of', 2], ['big', 3]], big_text: true
            end
            items.item do |item|
              item.split_header %w[Split Header]
              item.add_percentage 85, large: true
              item.add_table [%w[A table no col]], nil, 'Basic table, no cols'
            end
            items.item do |item|
              item.split_header [%w[Split Header], %w[with val]]
              item.add_label 'Lbl centre', center: true, large: true
              item.add_table [{ a: 'but', table: 'no', with: 'border', col: 'though' }], %i[a table with col], nil, no_border: true
            end
            items.item do |item|
              item.header 'Head with value'
              item.header_value 'abc'
              item.add_percentage 0, sub_text: 'Large - and subtext', large: true
              item.add_label 'Label'
              item.add_label 'Label - centre w/colour', center: true, colour: :orange
              item.add_label_val 'Label w/val', 'val'
              item.add_number 123, bg: :blue
            end
            items.item do |item|
              item.add_rich_table [{ left: nil,
                                     center: { type: :head_col,
                                               header: 'TOTAL',
                                               bg: :gray },
                                     right: { type: :table,
                                              header: 'PALLETS',
                                              align: :right,
                                              table: [['Cartons', 123], ['Pallets', 123]] } },
                                   { left: { type: :table,
                                             header: 'SHIPPED (123)',
                                             align: :right,
                                             table: [['Cartons', 123], ['Pallets', 123]] },
                                     center: { type: :head_col,
                                               header: 'LOAD',
                                               bg: :gray },
                                     right: { type: :table,
                                              header: 'ALLOCATED (123}',
                                              align: :right,
                                              table: [['Cartons', 123], ['Pallets', 123]] } },
                                   { left: { type: :table,
                                             header: 'VERIFIED',
                                             align: :right,
                                             table: [['Cartons', 123], ['Pallets', 123]] },
                                     center: { type: :head_col,
                                               header: 'VERIFY',
                                               bg: :gray },
                                     right: { type: :table,
                                              header: 'UNVERIFIED',
                                              align: :right,
                                              table: [['Cartons', 123], ['Pallets', 123]] } }]
            end
          end
        end

        dash.lane do |lane|
          lane.caption 'Device dash'
          lane.sub_caption ['a str 1', 'a str 2', 'a str 3', 'a str 4'].compact
          lane.item_set do |items|
            items.item do |item|
              item.no_stretch!
              item.add_network_state label: 'DEV-01',
                                     ping_label: 'Network',
                                     run_label: 'Software',
                                     ping_state: :undef,
                                     run_state: :undef,
                                     dom_id_base: 'id1'
              item.add_label 'CENTRE', center: true
              item.add_label 'Individual Incentive', center: true, banner: :blue
              item.add_label_val 'Login on reader', 'sometime', font_weight: :normal
              table_opts = { rows: [{ button: 'btn1', setup: 'set1', label: 'lbl1' }], cols: %i[button setup label] }
              item.add_popup_button 'Button allocations', popup_table: table_opts
            end
            items.item do |item|
              item.no_stretch!
              item.add_network_state label: 'DEV-01',
                                     ping_label: 'Network',
                                     run_label: 'Software',
                                     ping_state: :ok,
                                     run_state: :notok,
                                     dom_id_base: 'id2'
              item.add_label 'CENTRE', center: true
              item.add_label 'Group Incentive', banner: :purple
              item.add_label 'Active group members', center: true
            end
          end
        end

        dash.lane do |lane|
          lane.caption 'Lane caption'
          lane.no_data 'This is a lane showing that there is no data to display'
        end
        ar << dash.render
        ar.join(separator)
      end

      def generate_tab_set
        ar = [head('Tab Set', 'tab_set')]
        sets = [[nil, nil, [{ text: 'One', url: '/' }, { text: 'A second tab', url: '/' }, { text: '3', url: '/', disabled: true }, { text: 'The fourth is the widest', url: '/' }]],
                [1, nil, [{ text: 'One', url: '/' }, { text: 'A second tab', url: '/' }, { text: 'Three', url: '/' }, { text: 'The fourth is the widest', url: '/' }]]]
        sets.each do |active, target, items|
          ar << TabSet.new({}, items, { active_tab_index: active, target_dom_id: target }).render
        end
        ar.join(separator)
      end

      def generate_colours
        cols = %w[black blue gray green ocean orange purple red sky slate yellow zinc]
        nos = %w[50 100 200 300 400 500 600 700 800 900]
        ar = [head('Colour classes', 'colours')]
        cols.each do |col|
          ar << <<~HTML
            <span class="font-medium">#{col}</span><br>
            #{nos.map { |n| %(<div class="p-2"><div class="inline-block w-52 p-2 bg-#{col}-#{n}">BG #{col}-#{n}</div><div class="inline-block w-52 p-2 border rounded-2 border-#{col}-#{n}">BORDER #{col}-#{n}</div><div class="inline-block w-52 p-2 text-#{col}-#{n}">TEXT #{col}-#{n}</div></div>) }.join("\n")}
          HTML
        end
        StylesConfig.config.grid_row_colours.each do |key, cls|
          ar << %(<span class="#{cls}">Grid row colour "#{key}"</span><br>)
        end
        ar.join(separator)
      end

      def generate_layout_grid
        ar = [head('LayoutGrid', 'layout_grid')]
        lay = LayoutGrid.new({})
        lay.specify_row 1
        lay.specify_row 2
        lay.specify_row 3
        lay.specify_row 4
        lay.specify_row 6
        lay.specify_row 12
        3.times do |cnt|
          lay.add_kpi_card "Col #{cnt + 1}", "KPI #{cnt + 1}"
        end
        25.times do |cnt|
          lay.add_text "Col #{cnt + 4}"
        end
        ar << lay.render
        ar.join(separator)
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/BlockLength
