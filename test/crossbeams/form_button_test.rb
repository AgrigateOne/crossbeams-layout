require 'test_helper'

class Crossbeams::Layout::FormButtonTest < Minitest::Test
  def render_button(options = {})
    caption = options.delete(:caption) || 'Cap'
    formaction = options.delete(:formaction) || '/'
    form_remote = options.delete(:form_remote) || false

    button = Crossbeams::Layout::FormButton.new(caption, formaction, options)
    # p button.render(remote)
    RenderResult.new(button.render(form_remote))
  end

  def test_defaults
    html = render_button
    assert_equal 'Cap', html.dom_text_value('button')
    attrs =  html.input_attributes('button')
    assert_equal 'commit', attrs['name']
    assert_equal 'submit', attrs['type']
    assert_equal '/', attrs['formaction']
    assert_nil attrs['data-remote']
    assert_nil attrs['disabled']
    assert_nil attrs['id']
    assert_equal 'Submitting...', attrs['data-disable-with']
    classes = attrs['class'].split(' ')
    assert_includes classes, 'bg-gray'
  end

  def test_options
    html = render_button(caption: 'Xyz',
                         formaction: '/other',
                         name: 'xAx',
                         disable_with: 'XXX',
                         colour: 'red',
                         dom_id: 'aa',
                         disabled: true)
    assert_equal 'Xyz', html.dom_text_value('button')
    attrs =  html.input_attributes('button')
    assert_equal '/other', attrs['formaction']
    assert_equal 'true', attrs['disabled']
    assert_equal 'aa', attrs['id']
    assert_equal 'xAx', attrs['name']
    assert_equal 'XXX', attrs['data-disable-with']
    classes = attrs['class'].split(' ')
    assert_includes classes, 'bg-red'
  end

  # Button remote inherits the remote setting of the form (specified as "form_remote" in tests).
  # BUT if remote is specified for the button, it overrides the form setting.
  def test_remote
    html = render_button(form_remote: true)
    attrs =  html.input_attributes('button')
    assert_equal 'true', attrs['data-remote']

    html = render_button(form_remote: false)
    attrs =  html.input_attributes('button')
    assert_nil attrs['data-remote']

    html = render_button(form_remote: false, remote: true)
    attrs =  html.input_attributes('button')
    assert_equal 'true', attrs['data-remote']

    html = render_button(form_remote: true, remote: false)
    attrs =  html.input_attributes('button')
    assert_nil attrs['data-remote']
  end
end
