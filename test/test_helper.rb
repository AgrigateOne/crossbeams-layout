$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'crossbeams/layout'

require 'minitest/autorun'
require 'bigdecimal'
require 'nokogiri'
require 'minitest/rg'

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

  def selected_value
    xp = @doc.xpath("//option[@selected]")
    return nil if xp.length.zero?
    xp[0].attributes['value'].value
  end

  def option_values(with_optgroup = false)
    xp = if with_optgroup
           @doc.xpath("//select/optgroup/option/@value")
         else
           @doc.xpath("//select/option/@value")
         end
    xp.map { |x| x.value }
  end

  def option_labels(with_optgroup = false)
    xp = if with_optgroup
           @doc.xpath("//select/optgroup/option")
         else
           @doc.xpath("//select/option")
         end
    # xp = @doc.xpath("//select/option")
    xp.map { |x| x.children }.flatten.map { |x| x.text }
  end

  def disabled_option
    xp = @doc.xpath('//select/option[@disabled]')
    return nil if xp.length.zero?
    xp[0].attribute('value').value
  end
end

def html_element_attribute_value(html_string, element_type, attribute)
  RenderResult.new(html_string).input_attributes(element_type)[attribute.to_s]
end

def html_datalist_element(html_string)
  RenderResult.new(html_string).datalist
end

def html_selected_value(html_string)
  RenderResult.new(html_string).selected_value
end

def html_select_disabled_value(html_string)
  RenderResult.new(html_string).disabled_option
end

def html_select_values(html_string, with_optgroup = false)
  RenderResult.new(html_string).option_values(with_optgroup)
end

def html_select_labels(html_string, with_optgroup = false)
  RenderResult.new(html_string).option_labels(with_optgroup)
end

def simple_input_render(renderer, value, extra_configs = {})
  page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(the_test_field: value) })
  field_name = :the_test_field
  field_config = { renderer: renderer }.merge(extra_configs)
  factory = Crossbeams::Layout::Renderer::FieldFactory.new(field_name, field_config, page_config)
  factory.render
end

def simple_select_render(value, list, extra_configs = {})
  config_opts = { name: 'test_form', form_object: OpenStruct.new(the_test_field: value) }
  form_value = extra_configs.delete(:form_value)
  config_opts[:form_values] = { the_test_field: form_value } unless form_value.nil?
  page_config = Crossbeams::Layout::PageConfig.new(config_opts)
  field_name = :the_test_field
  field_config = { renderer: :select, options: list }.merge(extra_configs)
  input = Crossbeams::Layout::Renderer::Select.new
  input.configure(field_name, field_config, page_config)
  input.render
end
