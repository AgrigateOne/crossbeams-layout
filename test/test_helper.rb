$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'crossbeams/layout'

require 'minitest/autorun'
require 'bigdecimal'
require 'nokogiri'

class RenderResult
  def initialize(html)
    @doc = Nokogiri::HTML(html)
  end

  def input_attributes(element_type)
    xp = @doc.xpath("//#{element_type}")
    Hash[xp[0].attributes.map { |k,v| [k, v.value] }]
  end

  def datalist
    xp = @doc.xpath("//datalist")
    {
      name: xp[0].attributes['id'].value,
      length: xp[0].children.length,
      list: xp[0].children.select { |c| c.attributes.key?('value') }.map { |c| c.attributes['value'].text }
    }
  end
end

def html_element_attribute_value(html_string, element_type, attribute)
  RenderResult.new(html_string).input_attributes(element_type)[attribute.to_s]
end

def html_datalist_element(html_string)
  RenderResult.new(html_string).datalist
end

def simple_input_render(renderer, value, extra_configs = {})
  page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(the_test_field: value) })
  field_name = :the_test_field
  field_config = { renderer: renderer }.merge(extra_configs)
  input = Crossbeams::Layout::Renderer::Input.new
  input.configure(field_name, field_config, page_config)
  input.render
end

def simple_select_render(value, list, extra_configs = {})
  page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(the_test_field: value) })
  field_name = :the_test_field
  field_config = { renderer: :select }.merge(extra_configs)
  input = Crossbeams::Layout::Renderer::Select.new
  input.configure(field_name, field_config, page_config)
  input.render
end
