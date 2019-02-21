# frozen_string_literal: true

require 'test_helper'

class Crossbeams::InputTest < Minitest::Test
  def test_required_config
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    assert_raises(KeyError) { lookup.configure(field_name, field_config, page_config) }

    field_config = { renderer: :lookup, lookup_name: 'locn' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    assert_raises(KeyError) { lookup.configure(field_name, field_config, page_config) }

    field_config = { renderer: :lookup, lookup_key: 'std' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    assert_raises(KeyError) { lookup.configure(field_name, field_config, page_config) }
  end

  def test_basics
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std' } # .merge(extra_configs)
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    assert_nil lookup.show_field
    assert_equal [], lookup.hidden_fields
    assert_equal 'locn', lookup.lookup_name
    assert_equal 'std', lookup.lookup_key
    s = lookup.render
    assert s.include?('Lookup The Test Field</button')
    assert_equal 'Lookup The Test Field', html_lookup_button_caption(s)

    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', caption: 'Something' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal 'Something', html_lookup_button_caption(s)
    assert_equal 'locn', html_lookup_button_data(s, 'lookup-name')
    assert_equal 'std', html_lookup_button_data(s, 'lookup-key')
  end

  def test_show_field
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', show_field: :a_show } # .merge(extra_configs)
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal '', html_lookup_show(s)[:value]

    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa', a_show: 'bbb') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', show_field: :a_show } # .merge(extra_configs)
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal 'bbb', html_lookup_show(s)[:value]
    assert_equal 'test_form[a_show]', html_lookup_show(s)[:name]
    assert_equal 'test_form_a_show', html_lookup_show(s)[:id]

    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa', a_show: 'bbb'),
                    form_values: { a_show: 'xxx' } }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', show_field: :a_show } # .merge(extra_configs)
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal 'xxx', html_lookup_show(s)[:value]
  end

  def test_hidden
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal [], html_lookup_hidden(s)

    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa', hide_1: 'bbb') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', hidden_fields: [:hide_1, :hide_2] }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    res = html_lookup_hidden(s)
    assert_equal ['bbb', ''], res.map { |h| h[:value] }

    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa', hide_1: 'bbb'),
                    form_values: { hide_1: 'xxx', hide_2: 'yyy' } }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', hidden_fields: [:hide_1, :hide_2, :hide_3] }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    res = html_lookup_hidden(s)
    assert_equal ['xxx', 'yyy', ''], res.map { |h| h[:value] }
  end

  def test_param_keys
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal '[]', html_lookup_button_data(s, 'param-keys')

    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', param_keys: [:some_form_id, :another_form_id] }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal '["some_form_id","another_form_id"]', html_lookup_button_data(s, 'param-keys')
  end

  def test_param_values
    config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: 'aaa') }
    page_config = Crossbeams::Layout::PageConfig.new(config_opts)
    field_name = :the_test_field
    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std' }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal '{}', html_lookup_button_data(s, 'param-values')

    field_config = { renderer: :lookup, lookup_name: 'locn', lookup_key: 'std', param_values: { some_form_id: '123', another_form_id: 12 } }
    lookup = Crossbeams::Layout::Renderer::Lookup.new
    lookup.configure(field_name, field_config, page_config)
    s = lookup.render
    assert_equal '{"some_form_id":"123","another_form_id":"12"}', html_lookup_button_data(s, 'param-values')
  end
end
