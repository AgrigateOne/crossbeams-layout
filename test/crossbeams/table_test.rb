require 'test_helper'

class Crossbeams::TableTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def test_basic
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols)
    assert_equal [{ a: 1, b: 2 }, { a: 3, b: 4 }], renderer.rows
    assert_equal [:a, :b], renderer.columns
    assert renderer.options[:has_columns]
    assert renderer.render.include?('<th>A</th>')
    assert renderer.render.match?(/<td\s*>1<\/td>/)
  end

  def test_no_cols
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, nil)
    assert_equal [:a, :b], renderer.columns
  end

  def test_2d_array
    rows = [['One', 2], ['Two', 4]]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, nil)
    refute renderer.options[:has_columns]
    refute renderer.render.include?('<thead>')
    assert renderer.render.include?('<td>One</td>')
  end

  def test_no_rows
    renderer = Crossbeams::Layout::Table.new(page_config, nil, nil)
    assert_equal [], renderer.rows
    assert_equal '', renderer.render
  end

  def test_alignment
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, alignment: { b: :right})
    assert renderer.render.match?(/<td align="right"\s*>2<\/td>/)
  end

  def test_cell_class
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, cell_classes: { a: ->(a) { a && a > 1 ? 'red' : '' }})
    assert renderer.render.match?(/<td\s+class='red'>3<\/td>/)
  end

  def test_pivot
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, pivot: true)
    assert renderer.render.match?(/<th align='right'>A<\/th><td\s+>1<\/td>/)
  end

  def test_caption
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, caption: 'Something')
    assert renderer.render.include?('<caption>Something</caption>')
  end

  def test_top_margin
    rows = [{ a: 1, b: 2 }, { a: 3, b: 4 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, top_margin: 2)
    assert renderer.render.include?('class="thinbordertable mt2"')
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, top_margin: 6)
    assert renderer.render.include?('class="thinbordertable mt6"')

    assert_raises(ArgumentError) { Crossbeams::Layout::Table.new(page_config, rows, cols, top_margin: 8).render }
    assert_raises(ArgumentError) { Crossbeams::Layout::Table.new(page_config, rows, cols, top_margin: -1).render }
    assert_raises(ArgumentError) { Crossbeams::Layout::Table.new(page_config, rows, cols, top_margin: '2').render }
  end

  def test_wrapper_div
    renderer = Crossbeams::Layout::Table.new(page_config, [], [])
    assert_equal '', renderer.render

    renderer = Crossbeams::Layout::Table.new(page_config, [], [], dom_id: 'abc')
    assert_equal '<div id="abc"></div>', renderer.render

    rows = [{ a: 1, b: 2 }]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, [])
    refute renderer.render.include?('<div id="abc">')
    renderer = Crossbeams::Layout::Table.new(page_config, rows, [], dom_id: 'abc')
    assert renderer.render.include?('<div id="abc">')
  end

  def test_transform_data
    rows = [{ a: 1, b: 2 }]
    cols = [:a, :b]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols)
    assert renderer.render.include?('<td>1</td>')

    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, cell_transformers: { a: ->(a) { "==#{a}==" }})
    assert renderer.render.include?('<td>==1==</td>')

    rows = [{ a: BigDecimal('1.2'), b: BigDecimal('2') }]
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, cell_transformers: { a: :decimal })
    assert renderer.render.include?('<td>1.20</td>')
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, cell_transformers: { a: :decimal_4 })
    assert renderer.render.include?('<td>1.2000</td>')
    renderer = Crossbeams::Layout::Table.new(page_config, rows, cols, cell_transformers: { a: :integer })
    assert renderer.render.include?('<td>1</td>')
  end
end
