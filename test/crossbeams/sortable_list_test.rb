require 'test_helper'

class Crossbeams::SortableListTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def test_basic
    items = [['one', 1], ['two', 2], ['three', 3]]
    renderer = Crossbeams::Layout::SortableList.new(page_config, 'pre', items)
    assert renderer.render.include?('one</li>')
  end

  def test_items
    assert_raises(ArgumentError) { Crossbeams::Layout::SortableList.new(page_config, 'pre', [1,2]) }
    assert_raises(ArgumentError) { Crossbeams::Layout::SortableList.new(page_config, 'pre', [[1,2,3]]) }
  end
end
