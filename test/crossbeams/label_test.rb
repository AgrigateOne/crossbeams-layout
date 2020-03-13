require 'test_helper'

class Crossbeams::LabelTest < Minitest::Test

  def test_basic
    s = simple_label_render('The label')
    assert_equal 'The Test Field', html_element_field_caption(s)
    assert_equal 'The label', html_label_element_value(s)
  end

  def test_time_formats
    # TODO: make this zone offset universal
    time = Time.new(2020, 1, 1, 11, 34, 21)
    time_str = '2020-01-01 11:34:21 +0200'
    s = simple_label_render(time)
    assert_equal '2020-01-01 11:34:21 +0200', html_label_element_value(s)

    s = simple_label_render(time, format: :without_timezone)
    assert_equal '2020-01-01 11:34:21', html_label_element_value(s)

    s = simple_label_render(time, format: :without_timezone_or_seconds)
    assert_equal '2020-01-01 11:34', html_label_element_value(s)

    s = simple_label_render(time_str)
    assert_equal '2020-01-01 11:34:21 +0200', html_label_element_value(s)

    s = simple_label_render(time_str, format: :without_timezone)
    assert_equal '2020-01-01 11:34:21', html_label_element_value(s)

    s = simple_label_render(time_str, format: :without_timezone_or_seconds)
    assert_equal '2020-01-01 11:34', html_label_element_value(s)
  end
end

