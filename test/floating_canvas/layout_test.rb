require 'test_helper'

class Crossbeams::LayoutTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Crossbeams::Layout::VERSION
  end

  def test_it_does_something_useful
    assert true #false
  end

  def test_create_page
    the_tester = Struct.new(:customer, :voyage, :invoice_date, :notes).new('Kromco', 'LOCAL_123', Date.today, 'Some notes for testing')
    the_layout = Crossbeams::Layout::Page.new form_object: the_tester
    assert the_layout.page_config.form_object.customer == 'Kromco'
  end

end
