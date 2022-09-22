require 'test_helper'

class Crossbeams::RadioGroupTest < Minitest::Test

  def test_basics
    s = simple_radio_render('o', [['one', 'o'], ['two', 't']])
    assert_equal 'radio', html_element_attribute_value(s, :input, :type)
    # assert_equal 'Test', html_element_field_caption(s)
  end
end
