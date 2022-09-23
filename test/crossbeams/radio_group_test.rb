require 'test_helper'

class Crossbeams::RadioGroupTest < Minitest::Test

  BASIC_OPTIONS = [['one', 'o'], ['two', 't']]

  def test_basics
    s = simple_radio_render('o', BASIC_OPTIONS)

    radios = html_elements_attributes(s, :input)
    assert radios.all? { |l| l['type'] == 'radio' }
    assert radios.all? { |l| l['name'] == 'test_form[the_test_field]' }
    assert radios.all? { |l| l['id'] == "test_form_the_test_field_#{l['value']}" }
    assert_equal ['o', 't'], radios.map { |r| r['value'] }
    assert radios.first['checked']
    refute radios.last['checked']

    lbls = html_elements_attributes(s, :label)
    assert_includes lbls.map { |l| l['for'] }, 'test_form_the_test_field_o'

    captions = html_labels_text(s)
    assert_equal ['one', 'two', 'The Test Field'], captions
  end

  def test_tooltip
    s = simple_radio_render('o', BASIC_OPTIONS, tooltip: 'A test')
    lbls = html_elements_attributes(s, :label)
    assert_includes lbls.map { |l| l['title'] }, 'A test'
  end

  def test_validations
    assert_raises(ArgumentError) { simple_radio_render(nil, nil) }
    assert_raises(ArgumentError) { simple_radio_render(nil, ['one', 'two']) }
    assert_raises(ArgumentError) { simple_radio_render(nil, [['one', 'o'], ['two', 'o']]) }
    assert simple_radio_render(nil, [['one', 'o'], ['one', 't']])

    assert_raises(ArgumentError) { simple_radio_render(nil, BASIC_OPTIONS, disabled_options: [['one', 'o']]) }
    assert simple_radio_render(nil, BASIC_OPTIONS, disabled_options: ['one', 'o'])
  end

  def test_checked
    s = simple_radio_render('o', BASIC_OPTIONS)
    radios = html_elements_attributes(s, :input)
    assert radios.first['checked']

    s = simple_radio_render(nil, BASIC_OPTIONS)
    radios = html_elements_attributes(s, :input)
    assert radios.first['checked']

    s = simple_radio_render('invalid option', BASIC_OPTIONS)
    radios = html_elements_attributes(s, :input)
    assert radios.first['checked']

    s = simple_radio_render('t', BASIC_OPTIONS)
    radios = html_elements_attributes(s, :input)
    assert radios.last['checked']
    refute radios.first['checked']
  end

  def test_disabled
    s = simple_radio_render('o', BASIC_OPTIONS, disabled_options: ['t'])
    radios = html_elements_attributes(s, :input)
    assert radios.last['disabled']
    refute radios.first['disabled']

    s = simple_radio_render('o', BASIC_OPTIONS, disabled_options: ['o'])
    radios = html_elements_attributes(s, :input)
    assert radios.first['disabled']
    refute radios.last['disabled']

    s = simple_radio_render('o', BASIC_OPTIONS, disabled_options: ['invalid'])
    radios = html_elements_attributes(s, :input)
    refute radios.first['disabled']
    refute radios.last['disabled']
  end

  def test_hide_on_load
    s = simple_radio_render('o', BASIC_OPTIONS, hide_on_load: true)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_radio_render('o', BASIC_OPTIONS)
    attrs = html_element_wrapper(s)
    refute_includes attrs.keys, 'hidden'

    s = simple_radio_render('o', BASIC_OPTIONS, initially_visible: false)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_radio_render('o', BASIC_OPTIONS, initially_visible: false, hide_on_load: false)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_radio_render('o', BASIC_OPTIONS, initially_visible: true)
    attrs = html_element_wrapper(s)
    refute_includes attrs.keys, 'hidden'
  end
end
