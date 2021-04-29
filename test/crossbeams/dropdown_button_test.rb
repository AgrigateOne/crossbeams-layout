require 'test_helper'

class Crossbeams::DropdownButtonTest < Minitest::Test
  def basic_item(extra = {})
    [{ url: '/', text: 'ClickMe' }.merge(extra)]
  end

  def test_defaults
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'Links', items: basic_item)
    html = renderer.render
    assert_equal 'crossbeams-dropdown-button bn br2 bg-silver', html_element_attribute_value(html, 'div', 'class')
    assert_equal 'button', html_element_attribute_value(html, 'button', 'type')
    assert_equal 'Links', html_dom_text_value(html, 'button')
    assert_equal 'Y', html_elements_attribute_value(html, 'a', 'data-button-dropdown').first
    assert_equal '/', html_elements_attribute_value(html, 'a', 'href').first
    assert_equal 'db pa2 dim', html_elements_attribute_value(html, 'a', 'class').first
    assert_match(/ClickMe<\/a/, html)
  end

  def test_invalid_args
    assert_raises(ArgumentError) { Crossbeams::Layout::DropdownButton.new }
    assert_raises(KeyError) { Crossbeams::Layout::DropdownButton.new(items: basic_item) }

    assert_raises(ArgumentError) { Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(behaviour: :popup, loading_window: true)) }
    assert_raises(ArgumentError) { Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(behaviour: :replace_dialog, loading_window: true)) }
  end

  def test_styles
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_equal 'pointer f6 bn dim br2 ph3 pv2 dib white bg-silver', html_element_attribute_value(renderer.render, 'button', 'class')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, style: :button)
    assert_equal 'pointer f6 bn dim br2 ph3 pv2 dib white bg-silver', html_element_attribute_value(renderer.render, 'button', 'class')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, style: :small_button)
    assert_equal 'pointer bn dim br1 ph2 dib white bg-silver', html_element_attribute_value(renderer.render, 'button', 'class')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, style: :action_button)
    assert_equal 'pointer f6 bn dim br2 ph3 pv2 dib white bg-green', html_element_attribute_value(renderer.render, 'button', 'class')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, style: :back_button)
    assert_match(/<svg class=["|']cbl-icon["|']/, renderer.render)
  end

  def test_behaviour
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-popup-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-replace-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(behaviour: :default))
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-popup-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-replace-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(behaviour: :popup))
    assert_equal 'true', html_elements_attribute_value(renderer.render, 'a', 'data-popup-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-replace-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(behaviour: :replace_dialog))
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-popup-dialog').first
    assert_equal 'true', html_elements_attribute_value(renderer.render, 'a', 'data-replace-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(loading_window: true))
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-popup-dialog').first
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-replace-dialog').first
    assert_equal 'true', html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first
  end

  def test_grid
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-grid-id').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(grid_id: 'a_grid_id'))
    assert_equal 'a_grid_id', html_elements_attribute_value(renderer.render, 'a', 'data-grid-id').first
  end

  def test_prompt
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(prompt: 'Is this OK?'))
    assert_equal 'Is this OK?', html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(prompt: true))
    assert_equal 'Are you sure?', html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(prompt: false))
    assert_nil html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(prompt: 'y'))
    assert_equal 'Are you sure?', html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(prompt: 'Y'))
    assert_equal 'Are you sure?', html_elements_attribute_value(renderer.render, 'a', 'data-prompt').first
  end

  def test_loading_window
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_empty html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').compact

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(loading_window: true))
    assert_equal 'true', html_elements_attribute_value(renderer.render, 'a', 'data-loading-window').first
  end

  def test_visible
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, visible: false)
    assert html_element_attribute_value(renderer.render, 'div', 'hidden')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, visible: true)
    assert_nil html_element_attribute_value(renderer.render, 'div', 'hidden')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, visible: 'ANY NON-FALSE VALUE')
    assert_nil html_element_attribute_value(renderer.render, 'div', 'hidden')
  end

  def test_visible_items
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(visible: false))
    assert_equal [''],  html_elements_attribute_value(renderer.render, 'a', 'hidden')

    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item)
    assert_empty html_elements_attribute_value(renderer.render, 'a', 'hidden').compact
  end

  def test_id
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item, id: 'an_id')
    assert_equal 'an_id', html_element_attribute_value(renderer.render, 'div', 'id')
  end

  def test_item_id
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: basic_item(id: 'item_id'), id: 'an_id')
    assert_equal ['item_id'], html_elements_attribute_value(renderer.render, 'a', 'id')

    items = [{ url: '/', text: 'ClickMe', id: 'id1' }, { url: '/', text: 'ClickMe', id: 'id2' }]
    renderer = Crossbeams::Layout::DropdownButton.new(text: 'ClickMe', items: items, id: 'an_id')
    assert_equal %w[id1 id2], html_elements_attribute_value(renderer.render, 'a', 'id')
  end
end
