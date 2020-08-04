require 'test_helper'

module Crossbeams
  class LoadingMessageTest < Minitest::Test # rubocop:disable Style/Documentation
    def test_basic
      basic_snippet = <<~HTML
        <div class="content-target content-loading">
          <div></div><div></div><div></div>
        </div>
      HTML
      renderer = Crossbeams::Layout::LoadingMessage.new
      assert_nil renderer.caption
      assert_empty renderer.options
      assert_equal basic_snippet, renderer.render
    end

    def test_dom_id
      renderer = Crossbeams::Layout::LoadingMessage.new(dom_id: 'dom-id-here')
      assert_match(/<div id="dom-id-here"/, renderer.render)
    end

    def test_caption
      renderer = Crossbeams::Layout::LoadingMessage.new(caption: 'The Caption')
      assert_match(/<\/div>The Caption/, renderer.render)

      renderer = Crossbeams::Layout::LoadingMessage.new(caption: 'The Caption', wrap_for_centre: true)
      assert_match(/<\/div><p class="pa3">The Caption/, renderer.render)
    end
  end
end
