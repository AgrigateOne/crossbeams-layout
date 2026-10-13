require 'test_helper'

class Crossbeams::Layout::RMDPageTest < Minitest::Test
  def csrf_tag
    '<input name="csrf" type="hidden" value="token">'
  end

  def build_page(rmd_state = { scan_with_camera: false }, &block)
    Crossbeams::Layout::RMDPage.build(rmd_state, &block)
  end

  def render_page(page)
    page.add_csrf_tag(csrf_tag)
    page.render
  end

  def test_build_returns_page
    page = build_page { |p| p.title 'Test' }
    assert_instance_of Crossbeams::Layout::RMDPage, page
  end

  def test_title
    page = build_page { |p| p.title 'Receive pallet' }
    render = render_page(page)
    assert_match(/<h1.+>Receive pallet<\/h1>/, render)
  end

  def test_notices_from_rmd_state
    page = build_page(
      info_notice: 'Info text',
      success_notice: 'Success text',
      warning_notice: 'Warning text',
      error_notice: 'Error text'
    ) { |p| p.title 'Notices' }

    render = render_page(page)
    assert_match(/Info text/, render)
    assert_match(/Success text/, render)
    assert_match(/Warning text/, render)
    assert_match(/Error text/, render)
  end

  def test_notice_methods_with_caption
    page = build_page do |p|
      p.title 'Notices'
      p.info_notice 'Info body', caption: 'Info caption'
      p.error_notice 'Error body', caption: 'Error caption'
    end

    render = render_page(page)
    assert_match(/Info caption/, render)
    assert_match(/Info body/, render)
    assert_match(/Error caption/, render)
    assert_match(/Error body/, render)
  end

  def test_notices_from_entity
    entity = OpenStruct.new(
      info_notice: 'Entity info',
      success_notice: nil,
      warning_notice: 'Entity warning',
      error_notice: nil
    )
    page = build_page { |p| p.title 'Entity notices'; p.notices(entity) }
    render = render_page(page)
    assert_match(/Entity info/, render)
    assert_match(/Entity warning/, render)
    refute_match(/Entity success/, render)
  end

  def test_notes
    page = build_page do |p|
      p.title 'Notes'
      p.notes("Line one\nLine two")
    end

    render = render_page(page)
    assert_match(/Line one<br>Line two/, render)
  end

  def test_step_and_total
    page = build_page do |p|
      p.title 'Steps'
      p.step_and_total(2, 5)
    end

    render = render_page(page)
    assert_match(/step 2 of 5/, render)
  end

  def test_progress_indicator
    page = build_page do |p|
      p.title 'Progress'
      p.progress_indicator(2, 5, prefix: 'Loaded')
    end

    render = render_page(page)
    assert_match(/Loaded 2 of 5/, render)
    assert_match(/width: 40\.0%/, render)
    assert_equal 'Loaded', page.progress_prefix
    assert_equal 2, page.progress_val
    assert_equal 5, page.progress_max
  end

  def test_progress_indicator_validation
    page = Crossbeams::Layout::RMDPage.new
    assert_raises(ArgumentError) { page.progress_indicator('1', 5) }
    assert_raises(ArgumentError) { page.progress_indicator(1, 0) }
    assert_raises(ArgumentError) { page.progress_indicator(-1, 5) }
  end

  def test_table
    page = build_page do |p|
      p.title 'Table'
      p.table([['Key', 'Value'], ['Another', 'Entry']])
    end

    render = render_page(page)
    assert_match(/<table/, render)
    assert_match(/Key/, render)
    assert_match(/Value/, render)
    assert_match(/Another/, render)
    assert_match(/Entry/, render)
  end

  def test_add_text_and_button_link
    page = build_page do |p|
      p.title 'Extras'
      p.add_text('<p>Custom text</p>')
      p.button_link('/done', 'Finish')
    end

    render = render_page(page)
    assert_match(/Custom text/, render)
    assert_match(%r{href="/done"}, render)
    assert_match(/Finish/, render)
  end

  def test_form_receives_page_state
    validation = { error_message: 'Form failed', errors: { pallet: ['must be filled'] } }
    page = build_page(scan_with_camera: true, rmd_validation: validation) do |p|
      p.title 'Form state'
      p.form do |form|
        form.name :receive
        form.action '/receive/save'
        form.add_field :pallet, caption: 'Pallet', required: false
      end
    end

    render = render_page(page)
    assert_match(/Scan with camera/, render)
    assert_match(/Form failed/, render)
    assert_match(/must be filled/, render)
    assert_match(/name="receive\[pallet\]"/, render)
  end

  def test_add_csrf_tag_passes_to_forms
    page = build_page do |p|
      p.title 'CSRF'
      p.form do |form|
        form.name :test
        form.action '/save'
      end
    end

    page.add_csrf_tag(csrf_tag)
    assert_equal csrf_tag, page.nodes.first.csrf_tag
  end

  def test_includes_javascript
    page = build_page { |p| p.title 'JS' }
    refute page.includes_javascript?
  end
end
