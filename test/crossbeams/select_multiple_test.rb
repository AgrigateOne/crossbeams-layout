require 'test_helper'

class Crossbeams::SelectMultipleTest < Minitest::Test
  def test_basics
    s = simple_select_multiple_render(nil, ['a', 'b'])
    assert_nil html_selected_value(s)
    assert_equal 'searchable-multi-select', html_element_attribute_value(s, :select, :class)
    s = simple_select_multiple_render(nil, ['a', 'b'], disabled: true)
    assert_equal 'true', html_element_attribute_value(s, :select, :disabled)
    s = simple_select_multiple_render(nil, ['a', 'b'], selected: 'b')
    assert_equal 'b', html_selected_value(s)
    s = simple_select_multiple_render('b', ['a', 'b'])
    assert_equal 'b', html_selected_value(s)
    assert_raises(Crossbeams::Layout::Error) { simple_select_render('c', ['a', 'b']) }
    s = simple_select_multiple_render('b', ['a', 'b'], form_value: 'a')
    assert_equal 'a', html_selected_value(s)
  end

  def test_simple_option_values
    s = simple_select_multiple_render(nil, ['a', 'b'])
    assert_equal ['a', 'b'], html_select_values(s)
    s = simple_select_multiple_render(nil, ['a', 'b'])
    assert_equal ['a', 'b'], html_select_labels(s)
  end

  def test_complex_option_values
    s = simple_select_multiple_render(nil, [['a', '1'], ['b', '2']])
    assert_equal ['1', '2'], html_select_values(s)
    s = simple_select_multiple_render(nil, ['a', 'b'])
    assert_equal ['a', 'b'], html_select_labels(s)
  end

  def test_disabled_option
    s = simple_select_multiple_render(nil, ['a', 'b'], disabled_options: ['c', 'd'])
    assert_equal ['a', 'b'], html_select_values(s).sort
    assert_nil html_select_disabled_value(s)
    s = simple_select_multiple_render('c', ['a', 'b'], disabled_options: ['c', 'd'])
    assert_equal ['a', 'b', 'c'], html_select_values(s).sort
    assert_equal 'c', html_select_disabled_value(s)

    s = simple_select_multiple_render(nil, [['a', '1'], ['b', '2']], disabled_options: [['c', '3'], ['d', '4']])
    assert_equal ['1', '2'], html_select_values(s).sort
    assert_nil html_select_disabled_value(s)
    s = simple_select_multiple_render('3', [['a', '1'], ['b', '2']], disabled_options: [['c', '3'], ['d', '4']])
    assert_equal ['1', '2', '3'], html_select_values(s).sort
    assert_equal '3', html_select_disabled_value(s)
  end

  def test_prompt
    s = simple_select_multiple_render(nil, ['a', 'b'], prompt: true)
    assert_equal ['', 'a', 'b'], html_select_values(s).sort
    assert_equal ['Select one or more values', 'a', 'b'], html_select_labels(s)

    s = simple_select_multiple_render(nil, ['a', 'b'], prompt: 'MAKE A CHOICE')
    assert_equal ['', 'a', 'b'], html_select_values(s).sort
    assert_equal ['MAKE A CHOICE', 'a', 'b'], html_select_labels(s)
  end

  def test_optgroup
    opts = { 'grp1' => [['a', '1'], ['b', '2']], 'grp2' => [['e', '5'], ['f', '6']] }
    s = simple_select_multiple_render(nil, opts)
    assert_equal ['1', '2', '5', '6'], html_select_values(s, true)
  end

  def test_sort_items
    s = simple_select_multiple_render(nil, ['a', 'b'])
    assert_equal 'Y', html_element_attribute_value(s, :select, "data-sort-items")

    s = simple_select_multiple_render(nil, ['a', 'b'], sort_items: true)
    assert_equal 'Y', html_element_attribute_value(s, :select, "data-sort-items")

    s = simple_select_multiple_render(nil, ['a', 'b'], sort_items: false)
    assert_equal 'N', html_element_attribute_value(s, :select, "data-sort-items")
  end

  def test_min_charwidth
    s = simple_select_multiple_render(nil, ['a', 'b'], min_charwidth: 30)
    assert_equal 'min-width:30rem;', html_element_attribute_value(s, :div, :style)
  end
end
