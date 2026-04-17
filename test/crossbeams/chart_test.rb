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
end
