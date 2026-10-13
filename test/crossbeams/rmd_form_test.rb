require 'test_helper'

class Crossbeams::Layout::RMDFormTest < Minitest::Test
  def csrf_tag
    '<input name="csrf" type="hidden" value="token">'
  end

  def new_form
    form = Crossbeams::Layout::RMDForm.new
    form.name :test_form
    form.action '/test/save'
    form.add_csrf_tag(csrf_tag)
    form
  end

  def render_form(form)
    form.render
  end

  def test_render_requires_csrf_tag
    form = Crossbeams::Layout::RMDForm.new
    form.name :test_form
    form.action '/test/save'
    assert_raises(ArgumentError) { form.render }
  end

  def test_basic_form_render
    form = new_form
    form.add_field :pallet, caption: 'Pallet', required: false
    render = render_form(form)

    assert_match(/<form action="\/test\/save" method="POST"/, render)
    assert_match(/#{Regexp.escape(csrf_tag)}/, render)
    assert_match(/name="test_form\[pallet\]"/, render)
    assert_match(/id="test_form_pallet"/, render)
    assert_match(/value="Submit"/, render)
  end

  def test_field_values_and_caption
    form = new_form
    form.values(pallet: 'PLT-123', warehouse: 'A')
    form.add_field :pallet, caption: 'Pallet number', required: false
    form.add_label :warehouse, caption: 'Warehouse', no_bg: true
    render = render_form(form)

    assert_match(/value="PLT-123"/, render)
    assert_match(/id="test_form_warehouse_value">A/, render)
  end

  def test_add_scan_field
    form = new_form
    form.add_scan_field :pallet, scan_type: :pallet, caption: 'Pallet', required: false
    render = render_form(form)

    assert_match(/data-scanner="key248_all"/, render)
    assert_match(/data-scan-rule="pallet"/, render)
    assert_match(/placeholder="Scan Pallet"/, render)
    assert_match(/data-rmd-clear="y"/, render)
  end

  def test_add_scan_field_requires_scan_type
    form = new_form
    assert_raises(ArgumentError) { form.add_scan_field(:pallet, caption: 'Pallet') }
  end

  def test_add_scan_field_invalid_data_type
    form = new_form
    assert_raises(ArgumentError) { form.add_scan_field(:pallet, scan_type: :pallet, data_type: :invalid) }
  end

  def test_add_field_delegates_to_scan_field
    form = new_form
    form.add_field :pallet, scan: 'key248_all', scan_type: :any, caption: 'Pallet', required: false
    render = render_form(form)

    assert_match(/data-scanner="key248_all"/, render)
    assert_match(/data-scan-rule=""/, render)
  end

  def test_add_multiple_scan_fields
    form = new_form
    form.add_multiple_scan_fields(:pallet, 3, required: :first, captions: %w[First Second], scan_type: :pallet)
    render = render_form(form)

    assert_match(/name="test_form\[pallet_1\]"/, render)
    assert_match(/name="test_form\[pallet_2\]"/, render)
    assert_match(/name="test_form\[pallet_3\]"/, render)
    assert_match(/First/, render)
    assert_match(/Second/, render)
    assert_match(/Pallet 3/, render)
    assert_match(/name="test_form\[pallet_1\]" .+required/, render)
    refute_match(/name="test_form\[pallet_2\]" .+required/, render)
  end

  def test_add_hidden_field
    form = new_form
    form.values(token: 'abc')
    form.add_hidden_field(:token)
    render = render_form(form)

    assert_match(/type="hidden"/, render)
    assert_match(/name="test_form\[token\]"/, render)
    assert_match(/value="abc"/, render)
  end

  def test_add_select
    form = new_form
    form.values(mode: 'detailed')
    form.add_select :mode, items: %w[simple detailed], prompt: true, required: false
    render = render_form(form)

    assert_match(/<select/, render)
    assert_match(/Select a value/, render)
    assert_match(/value="detailed" selected/, render)
  end

  def test_add_toggle
    form = new_form
    form.values(active: 't')
    form.add_toggle :active, caption: 'Active'
    render = render_form(form)

    assert_match(/type="checkbox"/, render)
    assert_match(/value="t" checked/, render)
    assert_match(/type="hidden" value="f"/, render)
  end

  def test_add_section_header
    form = new_form
    form.add_section_header('Section one')
    render = render_form(form)

    assert_match(/Section one/, render)
    assert_raises(ArgumentError) { form.add_section_header('') }
    assert_raises(ArgumentError) { form.add_section_header('Info', style: :invalid) }
  end

  def test_add_prev_next_nav
    form = new_form
    form.add_prev_next_nav('/items/$:id$', [1, 2, 3], 2)
    render = render_form(form)

    assert_match(%r{href="/items/1"}, render)
    assert_match(/Previous/, render)
    assert_match(%r{href="/items/3"}, render)
    assert_match(/Next/, render)
  end

  def test_table_rows
    form = new_form
    form.add_table_start
    form.add_table_label(:warehouse, 'Cold store', caption: 'Warehouse')
    form.add_table_row(:status, ['Status', true, false])
    form.add_table_end
    render = render_form(form)

    assert_match(/Cold store/, render)
    assert_match(/Warehouse/, render)
    assert_match(/Status/, render)
  end

  def test_add_button_and_link
    form = new_form
    form.add_button('Cancel', '/cancel')
    form.add_link('/back', 'Back', prompt: 'Are you sure?')
    render = render_form(form)

    assert_match(/formaction="\/cancel"/, render)
    assert_match(/Cancel/, render)
    assert_match(%r{href="/back"}, render)
    assert_match(/data-prompt="Are you sure\?"/, render)
    assert_raises(ArgumentError) { form.add_button('', '/cancel') }
    assert_raises(ArgumentError) { form.add_button('Cancel', '') }
  end

  def test_add_status_leds
    form = new_form
    form.add_status_leds(:red)
    render = render_form(form)

    assert_match(/id="led_red" class="rmdLedLight bg-red-600"/, render)
    assert_match(/id="led_green" class="rmdLedLight bg-slate-300"/, render)
  end

  def test_form_errors
    form = new_form
    form.errors(
      error_message: 'Top level error',
      errors: { pallet: ['is invalid'], base: ['cannot save'] }
    )
    form.add_field :pallet, caption: 'Pallet', required: false
    form.add_field :warehouse, caption: 'Warehouse', required: false
    render = render_form(form)

    assert_match(/Top level error/, render)
    assert_match(/cannot save/, render)
    assert_match(/is invalid/, render)
    assert_match(/id="test_form_pallet" .+autofocus/, render)
    refute_match(/id="test_form_warehouse" .+autofocus/, render)
  end

  def test_submit_button_options
    form = new_form
    form.button_caption 'Save'
    form.button_id 'save_btn'
    form.button_initially_hidden!
    form.add_field :pallet, required: false
    render = render_form(form)

    assert_match(/id="save_btn"/, render)
    assert_match(/value="Save"/, render)
    assert_match(/type="submit".+ hidden/, render)
  end

  def test_small_submit_and_no_submit
    form = new_form
    form.small_submit!
    form.add_field :pallet, required: false
    render = render_form(form)
    assert_match(/justify-center/, render)

    form = new_form
    form.no_submit!
    form.add_link('/back', 'Back')
    render = render_form(form)
    refute_match(/type="submit"/, render)
    assert_match(/Back/, render)
  end

  def test_scan_with_camera
    form = new_form
    form.scan_with_camera(true)
    render = render_form(form)

    assert_match(/id="cameraScan"/, render)
    assert_match(/id="cameraLight"/, render)
  end

  def test_progress_section
    form = new_form
    form.progress('Uploading...')
    render = render_form(form)

    assert_match(/id="rmd-progress"/, render)
    assert_match(/Uploading\.\.\./, render)
    refute_match(/id="rmd-progress".+style="display:none"/, render)
  end

  def test_behaviours
    form = new_form
    form.behaviours do |b|
      b.enable :detail_field, when: :mode, changes_to: %w[detailed]
      b.dropdown_change :mode, notify: [{ url: '/lookups/modes', param_keys: %w[mode] }]
    end
    form.add_select :mode, items: %w[simple detailed], required: false
    form.add_field :detail_field, hide_on_load: true, required: false
    render = render_form(form)

    assert_match(/data-change-values="test_form_detail_field"/, render)
    assert_match(/data-enable-on-values="detailed"/, render)
    assert_match(/data-observe-change=/, render)
    assert_raises(ArgumentError) do
      form2 = new_form
      form2.add_field :mode, required: false
      form2.behaviours { |_| }
    end
  end

  def test_multipart_for_image
    form = new_form
    form.add_image :photo, caption: 'Photo'
    render = render_form(form)

    assert form.multipart
    assert_match(/enctype='multipart\/form-data'/, render)
    assert_match(/type="file"/, render)
  end
end
