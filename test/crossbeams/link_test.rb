require 'test_helper'

class Crossbeams::LinkTest < Minitest::Test
  def test_defaults
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/')
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip
  end

  def test_invalid_args
    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new }
    assert_raises(KeyError) { Crossbeams::Layout::Link.new(text: 'ClickMe') }
    assert_raises(KeyError) { Crossbeams::Layout::Link.new(url: '/') }

    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new(url: '/', text: 'ClickMe', behaviour: :popup, loading_window: true) }
    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new(url: '/', text: 'ClickMe', behaviour: :replace_dialog, loading_window: true) }
  end

  def test_styles
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :link)
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :button)
    assert_equal '<a href="/" class="f6 link dim br2 ph3 pv2 dib white bg-silver ">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :small_button)
    assert_equal '<a href="/" class="link dim br1 ph2 dib white bg-silver ">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :back_button)
    assert_match(/<svg class=["|']cbl-icon["|']/, renderer.render)
  end

  def test_behaviour
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', behaviour: :default)
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', behaviour: :popup)
    assert_equal '<a href="/" data-popup-dialog="true">ClickMe</a>', renderer.render.strip
  end

  def test_grid
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/')
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', grid_id: 'a_grid_id')
    assert_equal '<a href="/" data-grid-id="a_grid_id">ClickMe</a>', renderer.render.strip
  end

  def test_prompt
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/')
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', prompt: 'Is this OK?')
    assert_equal '<a href="/" data-prompt="Is this OK?">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', prompt: true)
    assert_equal '<a href="/" data-prompt="Are you sure?">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', prompt: false)
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', prompt: 'y')
    assert_equal '<a href="/" data-prompt="Are you sure?">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', prompt: 'Y')
    assert_equal '<a href="/" data-prompt="Are you sure?">ClickMe</a>', renderer.render.strip
  end

  def test_loading_window
    match_str = '<a href="/" data-loading-window="true"'
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', loading_window: 'Y')
    assert_equal match_str, renderer.render.strip[0, match_str.length]
  end
end
