require 'test_helper'
require 'json'

class Crossbeams::MethodBuilderTest < Minitest::Test
  def class_build(suffix, nodes)
    node_text = nodes.map(&:inspect).join(', ')
    Crossbeams::Layout.module_eval(<<~RB)
      class TstMod#{suffix}
        extend MethodBuilder

        build_methods_for #{node_text}
        attr_accessor :nodes

        def initialize
          @nodes = []
        end

        def top_node_classes
          @nodes.map { |n| n.class.name }
        end

        def page_config
          Crossbeams::Layout::PageConfig.new({ rules: {}, fields: {df: { left: 'a', right: 'b' }}})
        end

        def sequence
          1
        end
      end
    RB
  end

  def test_method_defs
    class_build('1', [:csrf, :table, :fold_up, :row, :text, :notice, :diff, :list, :sortable_list, :repeating_request, :address, :contact_method, :grid, :section])
    c = Crossbeams::Layout::TstMod1.new
    assert c.public_methods.include?(:add_csrf_tag)
    assert c.public_methods.include?(:add_table)
    assert c.public_methods.include?(:fold_up)
    assert c.public_methods.include?(:row)
    assert c.public_methods.include?(:add_text)
    assert c.public_methods.include?(:add_notice)
    assert c.public_methods.include?(:add_diff)
    assert c.public_methods.include?(:add_list)
    assert c.public_methods.include?(:add_sortable_list)
    assert c.public_methods.include?(:add_repeating_request)
    assert c.public_methods.include?(:add_address)
    assert c.public_methods.include?(:add_contact_method)
    assert c.public_methods.include?(:add_grid)
    assert c.public_methods.include?(:section)
  end

  def test_method_calls
    class_build('2', [:csrf, :table, :fold_up, :row, :text, :notice, :diff, :list, :sortable_list, :repeating_request, :address, :contact_method, :grid, :section])
    c = Crossbeams::Layout::TstMod2.new
    c.add_table [{a: 1, b: 2, c: 3}, {a: 3, b: 2, c: 1}], [:a, :b, :c]
    c.fold_up do |f|
      f.add_text :df
    end
    c.row do |r|
      r.column do |l|
        l.add_text 'ABC'
      end
    end
    c.add_text 'TEXT'
    c.add_notice 'NOTE'
    c.add_diff :df
    c.add_list [1,2]
    c.add_sortable_list 'sl', [1,2]
    c.add_repeating_request '/url', 12, 'ABC'
    c.add_address []
    c.add_contact_method []
    c.add_grid 'gridid', '/url'
    c.add_csrf_tag 'tag'
    c.section do |s|
      s.add_text 'SSS'
    end
    assert_equal ['Crossbeams::Layout::Table',
                  'Crossbeams::Layout::FoldUp',
                  'Crossbeams::Layout::Row',
                  'Crossbeams::Layout::Text',
                  'Crossbeams::Layout::Notice',
                  'Crossbeams::Layout::Diff',
                  'Crossbeams::Layout::List',
                  'Crossbeams::Layout::SortableList',
                  'Crossbeams::Layout::RepeatingRequest',
                  'Crossbeams::Layout::Address',
                  'Crossbeams::Layout::ContactMethod',
                  'Crossbeams::Layout::Grid',
                  'Crossbeams::Layout::Section'], c.top_node_classes
  end
end
