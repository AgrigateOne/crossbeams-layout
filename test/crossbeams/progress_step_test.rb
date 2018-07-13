require 'test_helper'

class Crossbeams::ProgressStepTest < Minitest::Test

  def test_position
    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2'])
    assert_equal 0, renderer.position

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2'], position: 1)
    assert_equal 1, renderer.position

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2'], position: -1)
    assert_equal 1, renderer.position

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2'], position: 77)
    assert_equal 1, renderer.position

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'], position: -77)
    assert_equal 2, renderer.position
  end

  def test_size
    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'])
    assert_equal :default, renderer.size

    assert_raises(ArgumentError) { Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'], size: :large) }

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'], size: :small)
    assert renderer.render.include?('max-width:30rem')

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'], size: :medium)
    assert renderer.render.include?('max-width:60rem')
  end

  def test_state_description
    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'])
    refute renderer.render.include?('<ul class="cbl-progress-state">')

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'], state_description: 'a description')
    assert_equal ['a description'], renderer.state_description
    assert renderer.render.include?('<ul class="cbl-progress-state">')
  end

  def test_step_widths
    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3'])
    assert renderer.render.include?('style="width: 33.33%;">')
    assert renderer.render.include?('<div class="cbl-progress-status-bar" style="width: 66.67%;">')

    renderer = Crossbeams::Layout::ProgressStep.new({}, ['1', '2', '3', '4'])
    assert renderer.render.include?('style="width: 25.0%;">')
    assert renderer.render.include?('<div class="cbl-progress-status-bar" style="width: 75.0%;">')
  end
end
