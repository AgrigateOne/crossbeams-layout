# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/ClassLength
module Crossbeams
  module Layout
    # Generate HTML examples
    class ExamplesGenerator
      attr_reader :classes

      def initialize(classes = :all)
        @classes = classes
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
        @out << generate_loading_message if %i[all loading_message].include? classes
        @out << generate_repeating_request if %i[all repeating_request].include? classes
        @out << generate_callback_section if %i[all callback_section].include? classes
        @out
      end

      private

      def build_contents # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        @out << '<h2>Contents</h2><ol>'
        @out << '<li><a href="#help_link">Help link</a></li>' if %i[all help_link].include? classes
        @out << '<li><a href="#link">Link (and as buttons)</a></li>' if %i[all link].include? classes
        @out << '<li><a href="#dropdown_button">Dropdown Button</a></li>' if %i[all dropdown_button].include? classes
        @out << '<li><a href="#icons">Icons</a></li>' if %i[all icon].include? classes
        @out << '<li><a href="#text">Text</a></li>' if %i[all text].include? classes
        @out << '<li><a href="#form">Form</a></li>' if %i[all form].include? classes
        @out << '<li><a href="#sections">Sections</a></li>' if %i[all section].include? classes
        @out << '<li><a href="#tables">Tables</a></li>' if %i[all table].include? classes
        @out << '<li><a href="#progress_step">Progress Step</a></li>' if %i[all progress_step].include? classes
        @out << '<li><a href="#list">List</a></li>' if %i[all list].include? classes
        @out << '<li><a href="#sortable_list">Sortable List</a></li>' if %i[all sortable_list].include? classes
        @out << '<li><a href="#row">Rows and Cols</a></li>' if %i[all row].include? classes
        @out << '<li><a href="#notice">Notice</a></li>' if %i[all notice].include? classes
        @out << '<li><a href="#foldup">Foldup</a></li>' if %i[all foldup].include? classes
        @out << '<li><a href="#address">Address</a></li>' if %i[all address].include? classes
        @out << '<li><a href="#contact_method">Contact</a></li>' if %i[all contact_method].include? classes
        @out << '<li><a href="#grid">Grid</a></li>' if %i[all grid].include? classes
        @out << '<li><a href="#diff">Diff</a></li>' if %i[all diff].include? classes
        @out << '<li><a href="#loading_message">Loading Mesage</a></li>' if %i[all loading_message].include? classes
        @out << '<li><a href="#repeating_request">Repeating Request</a></li>' if %i[all repeating_request].include? classes
        @out << '<li><a href="#callback_section">Callback Section</a></li>' if %i[all callback_section].include? classes
        @out << '</ol>'
      end

      def head(caption, anchor)
        %(<div class="tc b pv2 bt bl br mt4"><a name="#{anchor}">#{caption}</a></div>)
      end

      def separator
        '<hr class="mt1 blue">'
      end

      def generate_icons
        ar = [head('Icons', 'icons')]
        ar << '<table class="table-collapse"><thead><tr><th>Name</th><th class="br">Icon</th><th>Name</th><th class="br">Icon</th><th>Name</th><th class="br">Icon</th><th>Name</th><th>Icon</th></tr></thead><tbody>'
        # ar += Icon.available_icons.map { |i| %(<tr><td class="pa2">#{i}</td><td class="pa2">#{Icon.render(i)}</td></tr>) }
        Icon.available_icons.each_slice(4) { |i1, i2, i3, i4| ar << %(<tr><td class="pa2">#{i1}</td><td class="br pa2">#{Icon.render(i1)}</td><td class="pa2">#{i2}</td><td class="br pa2">#{Icon.render(i2)}</td><td class="pa2">#{i3}</td><td class="br pa2">#{Icon.render(i3)}</td><td class="pa2">#{i4}</td><td class="pa2">#{Icon.render(i4)}</td></tr>) }
        ar << '</tbody></table>'
        ar.join("\n")
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
        ar.join(separator)
      end

      def generate_row
        ar = [head('Row + Col', 'row')]
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'col1', css_classes: 'bg-orange'
        end
        row.column do |col|
          col.add_text 'col2', css_classes: 'bg-green'
        end
        ar << row.render
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'one-sided col (with blank)', css_classes: 'bg-orange'
        end
        row.blank_column
        ar << row.render
        row = Row.new({}, 1, 1)
        row.blank_column
        row.column do |col|
          col.add_text 'other-sided col (with blank)', css_classes: 'bg-green'
        end
        ar << row.render
        row = Row.new({}, 1, 1)
        row.column do |col|
          col.add_text 'col1 full width', css_classes: 'bg-orange'
        end
        row.column do |col|
          col.add_text 'col2 full width', css_classes: 'bg-green'
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
                                                 inp2: { required: true, caption: 'INP Two has a very long caption that wraps' },
                                                 dat1: { renderer: :date },
                                                 dat2: { renderer: :datetime, required: true, hint: '<h3>A hint</h3>For a datetime' },
                                                 chk1: { renderer: :checkbox },
                                                 chk2: { renderer: :checkbox, required: true, hint: '<h3>A hint</h3>For a checkbox' },
                                                 num1: { renderer: :integer, caption: 'Integer' },
                                                 num2: { renderer: :number, caption: 'Decimal', required: true },
                                                 mlt1: { renderer: :multi, options: %w[one two three four], required: true },
                                                 msl1: { renderer: :select_multiple, options: %w[one two three four], required: true, sort_items: false },
                                                 msl2: { renderer: :select_multiple, options: { 'Group1' => [['one', 1], ['two', 2]],
                                                                                                'Group2' => [['three', 3], ['four', 4]] }, sort_items: false },
                                                 rdo1: { renderer: :radio_group, options: [['Opt one', 'opt_one'], ['Opt two', 'opt_two']] },
                                                 txt1: { renderer: :textarea, required: true },
                                                 lst1: { renderer: :list, items: %w[one two three], required: true },
                                                 lst2: { renderer: :list, items: [['One', 1], ['Two', 2], ['Three', 3]], filled_background: true, remove_item_url: '/a/path/$:id$/remove' },
                                                 lkp1: { renderer: :lookup,
                                                         lookup_name: 'a_query',
                                                         lookup_key: 'a_key' },
                                                 lkp2: { renderer: :lookup,
                                                         caption: 'Lkp with field',
                                                         lookup_name: 'a_query',
                                                         lookup_key: 'a_key',
                                                         show_field: :fred,
                                                         required: true },
                                                 lbl1: { renderer: :label },
                                                 lbl2: { renderer: :label, with_value: 'A label' },
                                                 sel1: { renderer: :select, options: %w[one two three], disabled_options: %w[four], prompt: 'Select something', min_charwidth: 20 },
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
            col.add_field :mlt1
            col.add_field :rdo1
            col.add_field :txt1
          end
        end

        ar << frm.render

        page_config = PageConfig.new({ form_object: OpenStruct.new(inp1: nil), fields: { inp1: { caption: 'INP Inline', placeholder: 'like for search' } } })
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
                                       fields: { inp1: {}, inp2: { required: true } },
                                       form_errors: { base: ['A base validation error'], inp2: ['value required'] } })
        frm = Form.new(page_config, 1, 1)
        frm.form_id 'frm-err'
        frm.caption ' Form With Errors'
        frm.add_field :inp1
        frm.add_field :inp2
        ar << frm.render

        ar.join(separator)
      end

      # FORM + FORM-BUTTON + FIELDS
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/ClassLength
