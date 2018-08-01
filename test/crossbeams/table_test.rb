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
    assert renderer.render.include?('<th>a</th>')
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
end
