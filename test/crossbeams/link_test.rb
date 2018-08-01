require 'test_helper'

class Crossbeams::LinkTest < Minitest::Test
  def test_defaults
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/')
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip
  end

  def test_invalid_args
    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new }
    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new(text: 'ClickMe') }
    assert_raises(ArgumentError) { Crossbeams::Layout::Link.new(url: '/') }
  end

  def test_styles
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :link)
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :button)
    assert_equal '<a href="/" class="f6 link dim br2 ph3 pv2 dib white bg-silver">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', style: :back_button)
    assert_equal '<a href="/" class="f6 link dim br2 ph3 pv2 dib white bg-dark-blue"><i class=\'fa fa-arrow-left\'></i> ClickMe</a>', renderer.render.strip
  end

  def test_behaviour
    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', behaviour: :default)
    assert_equal '<a href="/">ClickMe</a>', renderer.render.strip

    renderer = Crossbeams::Layout::Link.new(text: 'ClickMe', url: '/', behaviour: :popup)
    assert_equal '<a href="/" data-popup-dialog="true">ClickMe</a>', renderer.render.strip
  end
end
