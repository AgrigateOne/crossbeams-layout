# frozen_string_literal: true

require 'test_helper'

class Crossbeams::ChartTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def sample_spec
    {
      '$schema' => 'https://vega.github.io/schema/vega-lite/v5.json',
      'data' => { 'values' => [{ 'a' => 'A', 'b' => 28 }, { 'a' => 'B', 'b' => 55 }] },
      'mark' => 'bar',
      'encoding' => {
        'x' => { 'field' => 'a', 'type' => 'nominal' },
        'y' => { 'field' => 'b', 'type' => 'quantitative' }
      }
    }
  end

  def test_renders_container_div
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'test-chart')
    html = chart.render

    assert_includes html, 'id="test-chart"'
    assert_includes html, 'id="test-chart-wrapper"'
  end

  def test_generates_unique_id_when_not_provided
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec)

    assert_match(/^chart-[a-f0-9]{8}$/, chart.chart_id)
  end

  def test_includes_spec_in_data_attribute
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'spec-chart')
    html = chart.render

    assert_includes html, 'data-chart-spec='
    assert_includes html, '"mark":"bar"'
  end

  def test_accepts_hash_spec
    spec = { mark: 'line', data: { values: [] } }
    chart = Crossbeams::Layout::Chart.new(page_config, spec, id: 'hash-chart')
    html = chart.render

    assert_includes html, '"mark":"line"'
  end

  def test_accepts_json_string_spec
    spec = '{"mark":"point","data":{"values":[]}}'
    chart = Crossbeams::Layout::Chart.new(page_config, spec, id: 'json-chart')
    html = chart.render

    assert_includes html, 'data-chart-spec='
  end

  def test_dom_loaded_contains_init_call
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'my-chart')

    assert chart.dom_loaded?
    js = chart.list_dom_loaded.join

    assert_includes js, "crossbeamsCharts.render('my-chart'"
  end

  def test_includes_embed_options_in_init
    chart = Crossbeams::Layout::Chart.new(
      page_config,
      sample_spec,
      id: 'opts-chart',
      embed_options: { actions: false, renderer: 'svg' }
    )
    js = chart.list_dom_loaded.join

    assert_includes js, '"actions":false'
    assert_includes js, '"renderer":"svg"'
  end

  def test_renders_caption
    chart = Crossbeams::Layout::Chart.new(
      page_config,
      sample_spec,
      id: 'caption-chart',
      caption: 'Sales by Region'
    )
    html = chart.render

    assert_includes html, 'Sales by Region'
  end

  def test_applies_height_option
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'height-chart', height: 400)
    html = chart.render

    assert_includes html, 'height: 400px'
  end

  def test_applies_width_option
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'width-chart', width: 600)
    html = chart.render

    assert_includes html, 'width: 600px'
  end

  def test_applies_string_dimensions
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec, id: 'dim-chart', width: '100%', height: '50vh')
    html = chart.render

    assert_includes html, 'width: 100%'
    assert_includes html, 'height: 50vh'
  end

  def test_invisible_returns_false
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec)

    refute chart.invisible?
  end

  def test_hidden_returns_false
    chart = Crossbeams::Layout::Chart.new(page_config, sample_spec)

    refute chart.hidden?
  end

  def test_page_integration
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_chart(sample_spec, id: 'page-chart', caption: 'Test Chart')
    end

    html = page.render
    assert_includes html, 'id="page-chart"'
    assert_includes html, 'Test Chart'

    assert page.includes_javascript?
    js = page.render_dom_loaded_js
    assert_includes js, "crossbeamsCharts.render('page-chart'"
  end

  def test_section_integration
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.section do |section|
        section.add_chart(sample_spec, id: 'section-chart')
      end
    end

    html = page.render
    assert_includes html, 'id="section-chart"'

    assert page.includes_javascript?
  end

  # Chart type convenience method tests

  def sample_data
    [{ category: 'A', value: 28 }, { category: 'B', value: 55 }, { category: 'C', value: 43 }]
  end

  def test_add_bar_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(sample_data, x_field: :category, y_field: :value, id: 'bar-chart')
    end

    html = page.render
    assert_includes html, 'id="bar-chart"'
    assert_includes html, '"type":"bar"'
    assert_includes html, '"field":"category"'
    assert_includes html, '"field":"value"'
  end

  def test_add_bar_chart_with_title
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(sample_data, x_field: :category, y_field: :value, id: 'titled-bar', title: 'Sales Chart')
    end

    html = page.render
    assert_includes html, '"text":"Sales Chart"'
  end

  def test_add_bar_chart_with_color_field
    data = [
      { category: 'A', value: 10, group: 'X' },
      { category: 'A', value: 20, group: 'Y' }
    ]
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(data, x_field: :category, y_field: :value, color_field: :group, id: 'grouped-bar')
    end

    html = page.render
    assert_includes html, '"color":'
    assert_includes html, '"field":"group"'
  end

  def test_add_line_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_line_chart(sample_data, x_field: :category, y_field: :value, id: 'line-chart')
    end

    html = page.render
    assert_includes html, 'id="line-chart"'
    assert_includes html, '"type":"line"'
  end

  def test_add_line_chart_with_points
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_line_chart(sample_data, x_field: :category, y_field: :value, show_points: true, id: 'line-points')
    end

    html = page.render
    assert_includes html, '"point":{'
    assert_includes html, '"filled":true'
  end

  def test_add_pie_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_pie_chart(sample_data, value_field: :value, category_field: :category, id: 'pie-chart')
    end

    html = page.render
    assert_includes html, 'id="pie-chart"'
    assert_includes html, '"type":"arc"'
    assert_includes html, '"theta":'
    assert_includes html, '"color":'
  end

  def test_add_donut_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_donut_chart(sample_data, value_field: :value, category_field: :category, id: 'donut-chart')
    end

    html = page.render
    assert_includes html, 'id="donut-chart"'
    assert_includes html, '"innerRadius":'
  end

  def test_add_area_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_area_chart(sample_data, x_field: :category, y_field: :value, id: 'area-chart')
    end

    html = page.render
    assert_includes html, 'id="area-chart"'
    assert_includes html, '"type":"area"'
  end

  def test_add_scatter_chart
    data = [{ x: 1, y: 2 }, { x: 3, y: 4 }]
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_scatter_chart(data, x_field: :x, y_field: :y, id: 'scatter-chart')
    end

    html = page.render
    assert_includes html, 'id="scatter-chart"'
    assert_includes html, '"type":"point"'
  end

  def test_section_add_bar_chart
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.section do |section|
        section.add_bar_chart(sample_data, x_field: :category, y_field: :value, id: 'section-bar')
      end
    end

    html = page.render
    assert_includes html, 'id="section-bar"'
    assert page.includes_javascript?
  end

  def test_chart_options_extraction
    options = Crossbeams::Layout::Chart.extract_options(
      id: 'test',
      height: 400,
      width: 600,
      caption: 'Test',
      embed_options: { actions: false },
      title: 'Ignored',
      color_field: :also_ignored
    )

    assert_equal 'test', options[:id]
    assert_equal 400, options[:height]
    assert_equal 600, options[:width]
    assert_equal 'Test', options[:caption]
    assert_equal({ actions: false }, options[:embed_options])
    refute options.key?(:title)
    refute options.key?(:color_field)
  end

  def test_spec_options_extraction
    options = Crossbeams::Layout::Chart.extract_spec_options(
      id: 'test',
      height: 400,
      width: 600,
      caption: 'Test',
      embed_options: { actions: false },
      title: 'Chart Title',
      color_field: :group,
      show_points: true
    )

    assert_equal 'Chart Title', options[:title]
    assert_equal :group, options[:color_field]
    assert_equal true, options[:show_points]
    refute options.key?(:id)
    refute options.key?(:height)
    refute options.key?(:width)
    refute options.key?(:caption)
    refute options.key?(:embed_options)
  end

  def test_convenience_chart_with_container_dimensions_still_has_spec_width_container
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(sample_data, x_field: :category, y_field: :value, id: 'sized-chart', width: '100%', height: 500)
    end

    html = page.render
    assert_includes html, '"width":"container"'
    assert_includes html, 'width: 100%'
    assert_includes html, 'height: 500px'
  end

  def test_chart_height_option_affects_spec
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(sample_data, x_field: :category, y_field: :value, id: 'spec-height', chart_height: 300)
    end

    html = page.render
    assert_includes html, '"height":300'
  end

  def test_convenience_chart_with_all_options
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_bar_chart(
        sample_data,
        x_field: :category,
        y_field: :value,
        id: 'full-opts',
        width: 800,
        height: 400,
        caption: 'Sales Report',
        embed_options: { actions: false },
        title: 'Monthly Sales',
        color_field: :category
      )
    end

    html = page.render
    assert_includes html, 'id="full-opts"'
    assert_includes html, 'width: 800px'
    assert_includes html, 'height: 400px'
    assert_includes html, 'Sales Report'
    assert_includes html, '"text":"Monthly Sales"'
    assert_includes html, '"width":"container"'

    js = page.render_dom_loaded_js
    assert_includes js, '"actions":false'
  end

  def test_line_chart_with_container_dimensions
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_line_chart(sample_data, x_field: :category, y_field: :value, id: 'line-sized', width: '100%', height: 300, show_points: true)
    end

    html = page.render
    assert_includes html, '"width":"container"'
    assert_includes html, '"point":{'
    assert_includes html, 'width: 100%'
  end

  def test_pie_chart_with_container_dimensions
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_pie_chart(sample_data, value_field: :value, category_field: :category, id: 'pie-sized', width: 400, height: 400)
    end

    html = page.render
    assert_includes html, '"width":"container"'
    assert_includes html, 'width: 400px'
  end
end
