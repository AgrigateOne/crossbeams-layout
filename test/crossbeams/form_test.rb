require 'test_helper'

class Crossbeams::Layout::FormTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def render_wrap(content)
    <<~HTML
      <div class="crossbeams-field no-flex">
      #{content}
      </div>
    HTML
  end

  def new_form
    Crossbeams::Layout::Form.new(page_config, 1, 1)
  end

  def test_caption
    form = new_form
    assert_nil form.form_caption
    render = form.render
    refute_match '<h2>', render

    form.caption 'A Caption'
    assert_equal 'A Caption', form.form_caption

    render = form.render
    assert_match '<h2>A Caption</h2>', render

    form.caption 'A Caption', level: 1
    render = form.render
    assert_match '<h1>A Caption</h1>', render

    form.caption 'A Caption'
    form.remote!
    assert form.remote_form
    render = form.render
    refute_match '<h2>A Caption</h2>', render

    assert_raises(ArgumentError) { form.caption 'X', level: 'a' }
    assert_raises(ArgumentError) { form.caption 'X', level: 5 }
  end

  def test_button
    form = new_form
    render = form.render
    assert_match '<input type="submit"', render

    form.button_id 'test_id'
    render = form.render
    assert_match '<input type="submit" id="test_id"', render
    refute_match ' hidden>', render

    form.initially_hide_button
    render = form.render
    assert_match ' hidden>', render
  end
end
