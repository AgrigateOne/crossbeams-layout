require 'test_helper'

class Crossbeams::NoticeTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def test_basic
    renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT')
    assert_equal 'TEXT', renderer.text
    assert_equal :info, renderer.notice_type
    assert_equal 'Note', renderer.caption
    assert renderer.show_caption
    assert renderer.within_field
  end

  def test_captions
    { info: 'Note',
      success: 'Success',
      warning: 'Warning',
      error: 'Error'
    }.each_pair do |type, caption|
      renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT', notice_type: type)
      assert_equal caption, renderer.caption
    end

    # Render without a caption:
    renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT', show_caption: false)
    refute_match(/<strong>/, renderer.render)

    # Render with a non-default caption:
    renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT', caption: 'Override')
    assert_equal 'Override', renderer.caption
    assert_match(/<strong>Override/, renderer.render)
  end

  def test_types
    %i[info success warning error].each do |type|
      Crossbeams::Layout::Notice.new(page_config, 'TEXT', notice_type: type)
    end
    assert_raises(ArgumentError) { Crossbeams::Layout::Notice.new(page_config, 'TEXT', notice_type: :nonsense_type) }
  end

  def test_render_box
    renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT')
    assert_match(/crossbeams-field/, renderer.render)

    renderer = Crossbeams::Layout::Notice.new(page_config, 'TEXT', within_field: false)
    refute_match(/crossbeams-field/, renderer.render)
  end
end

