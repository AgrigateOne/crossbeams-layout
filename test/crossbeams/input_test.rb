require 'test_helper'

class Crossbeams::InputTest < Minitest::Test

  def test_date_value
    s = simple_input_render(:date, Date.today)
    assert_equal 'date', html_element_attribute_value(s, :input, :type)
    assert_equal Date.today.strftime('%Y-%m-%d'), html_element_attribute_value(s, :input, :value)

    s = simple_input_render(:date, nil)
    assert_equal '', html_element_attribute_value(s, :input, :value)
  end

  def test_time_value
    the_time = Time.now
    s = simple_input_render(:input, the_time, subtype: :time)
    assert_equal 'time', html_element_attribute_value(s, :input, :type)
    assert_equal the_time.strftime('%H:%M'), html_element_attribute_value(s, :input, :value)

    s = simple_input_render(:time, nil)
    assert_equal '', html_element_attribute_value(s, :input, :value)
  end

  def test_boolean_attribute_values
    [:readonly, :disabled, :required].each do |attr|
      s = simple_input_render(:input, '123', attr => true)
      assert_equal 'true', html_element_attribute_value(s, :input, attr)

      s = simple_input_render(:input, '123', attr => false)
      assert_nil html_element_attribute_value(s, :input, attr)

      s = simple_input_render(:input, '123')
      assert_nil html_element_attribute_value(s, :input, attr)
    end
  end

  def test_placeholder_attribute
    s = simple_input_render(:input, '123', placeholder: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :placeholder)

    s = simple_input_render(:input, '123')
    assert_nil html_element_attribute_value(s, :input, :placeholder)
  end

  def test_title_attribute
    s = simple_input_render(:input, '123', title: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :title)

    s = simple_input_render(:input, '123')
    assert_nil html_element_attribute_value(s, :input, :title)

    s = simple_input_render(:input, '123', pattern_msg: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :title)

    s = simple_input_render(:input, '123', pattern_msg: 'will not appear', title: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :title)
  end

  def test_pattern_attribute
    s = simple_input_render(:input, '123', pattern: :no_spaces)
    assert_equal '[^\s]+', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123', pattern: :valid_filename)
    assert_equal '[^\s\/\\\*?:&"<>\\|]+', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123', pattern: :lowercase_underscore)
    assert_equal '[a-z_]*', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123', pattern: 'this SHOULD be a valid pattern')
    assert_equal 'this SHOULD be a valid pattern', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123', pattern: /^321$/)
    assert_equal '321', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123', pattern: '/^456$/')
    assert_equal '456', html_element_attribute_value(s, :input, :pattern)

    s = simple_input_render(:input, '123')
    assert_nil html_element_attribute_value(s, :input, :pattern)
  end

  def test_minlength_attribute
    s = simple_input_render(:input, '123', minlength: 12)
    assert_equal '12', html_element_attribute_value(s, :input, :minlength)

    s = simple_input_render(:input, '123')
    assert_nil html_element_attribute_value(s, :input, :minlength)

    assert_raises(ArgumentError) { simple_input_render(:integer, '123', minlength: 12) }
  end

  def test_minvalue_attribute
    s = simple_input_render(:integer, '123', minvalue: 12)
    assert_equal '12', html_element_attribute_value(s, :input, :min)

    s = simple_input_render(:integer, '123')
    assert_nil html_element_attribute_value(s, :input, :min)

    assert_raises(ArgumentError) { simple_input_render(:input, '123', minvalue: 12) }
  end

  def test_step_attribute
    s = simple_input_render(:numeric, 123)
    assert_equal 'any', html_element_attribute_value(s, :input, :step)
  end

  def test_upper_attribute
    s = simple_input_render(:input, '123', force_uppercase: true)
    assert_match 'toUpperCase', html_element_attribute_value(s, :input, :onblur)
  end

  def test_lower_attribute
    s = simple_input_render(:input, '123', force_lowercase: true)
    assert_match 'toLowerCase', html_element_attribute_value(s, :input, :onblur)
  end

  def test_datalist
    s = simple_input_render(:input, '123', datalist: ['a','b'])
    assert_equal 'test_form_the_test_field_listing', html_element_attribute_value(s, :input, :list)

    dl = html_datalist_element(s)
    assert_equal 'test_form_the_test_field_listing', dl[:name]
    assert_equal 3, dl[:length]
    assert_equal [], (['a', 'b'] - dl[:list])
  end

  def test_hide_on_load
    s = simple_input_render(:input, '123', hide_on_load: true)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_input_render(:input, '123')
    attrs = html_element_wrapper(s)
    refute_includes attrs.keys, 'hidden'

    s = simple_input_render(:input, '123', initially_visible: false)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_input_render(:input, '123', initially_visible: false, hide_on_load: false)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_input_render(:input, '123', initially_visible: true)
    attrs = html_element_wrapper(s)
    refute_includes attrs.keys, 'hidden'
  end

  def test_form_values
    s = simple_input_render(:input, '123', {}, the_test_field: '222')
    assert_equal '222', html_element_attribute_value(s, :input, :value)

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(id: 1, boss: { 'the_test_field' => '123' }) })
    page_config.form_values = { boss: { 'the_test_field' => '222' } }
    field_name = :the_test_field
    field_config = { renderer: :input, parent_field: :boss }
    factory = Crossbeams::Layout::Renderer::FieldFactory.new(field_name, field_config, page_config)
    s = factory.render
    assert_equal '222', html_element_attribute_value(s, :input, :value)

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(id: 1, boss: { the_test_field: '123' }) })
    page_config.form_values = { boss: { the_test_field: '222' } }
    field_name = :the_test_field
    field_config = { renderer: :input, parent_field: :boss }
    factory = Crossbeams::Layout::Renderer::FieldFactory.new(field_name, field_config, page_config)
    s = factory.render
    assert_equal '222', html_element_attribute_value(s, :input, :value)
  end
end
