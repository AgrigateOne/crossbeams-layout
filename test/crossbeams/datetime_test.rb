require 'test_helper'

class Crossbeams::DatetimeTest < Minitest::Test
  def assert_time_values(values, the_time)
    assert_includes values, the_time.strftime('%H:%M')
    assert_includes values, the_time.strftime('%Y-%m-%d')
    assert_includes values, the_time.strftime('%Y-%m-%dT%H:%M')
  end

  def test_time_value
    the_time = Time.now
    s = simple_input_render(:datetime, the_time)
    types = html_elements_attribute_value(s, :input, :type)
    assert_includes types, 'date'
    assert_includes types, 'time'
    assert_includes types, 'hidden'

    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, the_time)

    s = simple_input_render(:datetime, nil)
    values = html_elements_attribute_value(s, :input, :value)
    assert_equal values, ['', '', '']

    s = simple_input_render(:datetime, '')
    values = html_elements_attribute_value(s, :input, :value)
    assert_equal values, ['', '', '']
  end

  def test_form_values
    the_time = Time.now
    s = simple_input_render(:datetime, the_time)
    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, the_time)

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(id: 1, boss: { 'the_test_field' => the_time.strftime('%Y-%m-%dT%H:%M') }) })
    page_config.form_values = { boss: { 'the_test_field' => the_time.strftime('%Y-%m-%dT%H:%M') } }
    field_name = :the_test_field
    field_config = { renderer: :datetime, parent_field: :boss }
    factory = Crossbeams::Layout::Renderer::FieldFactory.new(field_name, field_config, page_config)
    s = factory.render
    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, the_time)

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(id: 1, boss: { the_test_field: the_time.strftime('%Y-%m-%dT%H:%M') }) })
    page_config.form_values = { boss: { the_test_field: the_time.strftime('%Y-%m-%dT%H:%M') } }
    field_name = :the_test_field
    field_config = { renderer: :datetime, parent_field: :boss }
    factory = Crossbeams::Layout::Renderer::FieldFactory.new(field_name, field_config, page_config)
    s = factory.render
    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, the_time)
  end

  def test_date_value
    s = simple_input_render(:datetime, Date.today)
    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, Date.today.to_time)
  end

  def test_datetime_value
    the_time = DateTime.now
    s = simple_input_render(:datetime, the_time)
    values = html_elements_attribute_value(s, :input, :value)
    assert_time_values(values, the_time)
  end

  def test_placeholder_attribute
    s = simple_input_render(:datetime, Time.now, placeholder: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :placeholder)

    s = simple_input_render(:datetime, Time.now)
    assert_nil html_element_attribute_value(s, :input, :placeholder)
  end

  def test_title_attribute
    s = simple_input_render(:datetime, Time.now, title: 'text')
    assert_equal 'text', html_element_attribute_value(s, :input, :title)

    s = simple_input_render(:datetime, Time.now)
    assert_nil html_element_attribute_value(s, :input, :title)
  end

  def test_minvalue_attribute
    s = simple_input_render(:datetime, Time.now, minvalue_date: '2020-01-01')
    assert_equal '2020-01-01', html_element_attribute_value(s, :input, :min)

    s = simple_input_render(:datetime, Time.now)
    assert_nil html_element_attribute_value(s, :input, :min)
  end

  def test_maxvalue_attribute
    s = simple_input_render(:datetime, Time.now, maxvalue_date: '2020-01-01')
    assert_equal '2020-01-01', html_element_attribute_value(s, :input, :max)

    s = simple_input_render(:datetime, Time.now)
    assert_nil html_element_attribute_value(s, :input, :max)
  end

  def test_hide_on_load
    s = simple_input_render(:datetime, Time.now, hide_on_load: true)
    attrs = html_element_wrapper(s)
    assert_includes attrs.keys, 'hidden'

    s = simple_input_render(:datetime, Time.now)
    attrs = html_element_wrapper(s)
    refute_includes attrs.keys, 'hidden'
  end
end

