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

  def inputs_attributes(element_type)
    xp = @doc.xpath("//#{element_type}")
    xp.map { |x| Hash[x.attributes.map { |k,v| [k, v.value] }] }
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

  def lookup_show
    xp = @doc.xpath('//input[@readonly]')
    return nil if xp.length.zero?
    {
      id: xp[0].attributes['id'].value,
      name: xp[0].attributes['name'].value,
      value: xp[0].attributes['value'].value
    }
  end

  def lookup_hidden
    xp = @doc.xpath('//input[@type="hidden"]')
    return [] if xp.length.zero?
    xp.map do |item|
      {
        id: item.attributes['id'].value,
        name: item.attributes['name'].value,
        value: item.attributes['value'].value
      }
    end
  end

  def lookup_button_caption
    xp = @doc.xpath('//button')
    xp.children.first.text
  end

  def lookup_button_data(key)
    xp = @doc.xpath('//button')
    xp.attribute("data-#{key}")&.value
  end

  def element_wrapper
    xp = @doc.xpath('//div')
    return {} if xp.length.zero?
    Hash[xp.first.attributes.map { |k, v| [v.name, v.value] }]
  end
end

def html_element_attribute_value(html_string, element_type, attribute)
  RenderResult.new(html_string).input_attributes(element_type)[attribute.to_s]
end

def html_elements_attribute_value(html_string, element_type, attribute)
  RenderResult.new(html_string).inputs_attributes(element_type).map { |a| a[attribute.to_s] }
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

def html_lookup_show(html_string)
  RenderResult.new(html_string).lookup_show
end

def html_lookup_hidden(html_string)
  RenderResult.new(html_string).lookup_hidden
end

def html_lookup_button_caption(html_string)
  RenderResult.new(html_string).lookup_button_caption
end

def html_lookup_button_data(html_string, key)
  RenderResult.new(html_string).lookup_button_data(key)
end

def html_element_wrapper(html_string)
  RenderResult.new(html_string).element_wrapper
end

def simple_input_render(renderer, value, extra_configs = {}, form_values = nil, form_errors = nil)
  page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(the_test_field: value) })
  page_config.form_values = form_values unless form_values.nil?
  page_config.form_errors = form_errors unless form_errors.nil?
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
