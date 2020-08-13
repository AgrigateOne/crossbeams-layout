require 'test_helper'

class Crossbeams::DiffTest < Minitest::Test

  def make_basic_record_diff(options = {})
    fields = { test_field: {
          left_caption: 'Before',
          right_caption: 'After',
          left_record: { fld1: 123, fld2: 'abc' },
          right_record: { fld1: 123, fld2: 'acb' }
    }}
    if options[:blank_captions]
      fields[:test_field].delete(:left_caption)
      fields[:test_field].delete(:right_caption)
    end
    if options[:compare_text]
      fields[:test_field].delete(:left_record)
      fields[:test_field].delete(:right_record)
      fields[:test_field][:left] = "123\nABC"
      fields[:test_field][:right] = "123\nACB"
    end

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    Crossbeams::Layout::Diff.new(page_config, :test_field)
  end

  def test_record_same
    renderer = make_basic_record_diff
    assert renderer.render.include?('<li class="unchanged"><span>fld1  : 123</span></li>')
  end

  def test_record_left
    renderer = make_basic_record_diff
    assert renderer.render.include?('<li class="del"><del>fld2  : a<strong>bc</strong></del></li>')
  end

  def test_record_right
    renderer = make_basic_record_diff
    assert renderer.render.include?('<li class="ins"><ins>fld2  : a<strong>cb</strong></ins></li>')
  end

  def test_caption
    renderer = make_basic_record_diff
    assert renderer.render.include?('<p class="cbl-diff-caption">Before</p>')
  end

  def test_caption_default
    renderer = make_basic_record_diff blank_captions: true
    assert renderer.render.include?('<p class="cbl-diff-caption">Left</p>')
  end

  def test_text_same
    renderer = make_basic_record_diff compare_text: true
    assert renderer.render.include?('<li class="unchanged"><span>123</span></li>')
  end

  def test_text_left
    renderer = make_basic_record_diff compare_text: true
    assert renderer.render.include?('<li class="del"><del>A<strong>BC</strong></del></li>')
  end

  def test_text_right
    renderer = make_basic_record_diff compare_text: true
    assert renderer.render.include?('<li class="ins"><ins>A<strong>CB</strong></ins></li>')
  end

  def test_arguments_invalid
    fields = { test_field: {
          right_record: { fld1: 123, fld2: 'acb' }
    }}

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    assert_raises(ArgumentError) {
      Crossbeams::Layout::Diff.new(page_config, :test_field)
    }

    fields = { test_field: {
          left: 'abc'
    }}

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    assert_raises(ArgumentError) {
      Crossbeams::Layout::Diff.new(page_config, :test_field)
    }

    fields = { test_field: {
          left: 'abc',
          right: 'abc',
          left_record: { fld1: 123, fld2: 'acb' },
          right_record: { fld1: 123, fld2: 'acb' }
    }}

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    assert_raises(ArgumentError) {
      Crossbeams::Layout::Diff.new(page_config, :test_field)
    }
  end

  def test_horizontal_scroll
    fields = { test_field: {
          left_caption: 'Before',
          right_caption: 'After',
          left_record: { fld1: 123, fld2: 'abc' },
          right_record: { fld1: 123, fld2: 'acb' },
          max_pane_width: 123
    }}
    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    renderer = Crossbeams::Layout::Diff.new(page_config, :test_field)

    assert renderer.render.include?('<div class="cbl-diff-container" style="max-width:123px">')
  end

  def test_nested_record
    left_rec = {
      zzz: {
        ddd: [3,2,1],
        ggg: [{a: 1, d: 2, b: 3}, {a: 2, d: 4, b: 6}],
        eee: {
          ff: 'aaa',
          dd: Date.new(2020, 5, 4),
          aa: 123,
          bb: BigDecimal.new('21.3')
        },
        ccc: 'aaa'
      },
      aaa: 'aa'
    }
    right_rec = {}

    fields = { test_field: {
          left_caption: 'Before',
          right_caption: 'After',
          left_record: left_rec,
          right_record: right_rec,
          unnest_records: true
    }}
    left_str = <<~STR
        <ul>
          <li class="del"><del>aaa          : aa</del></li>
          <li class="del"><del>zzz_ccc      : aaa</del></li>
          <li class="del"><del>zzz_ddd_1    : 3</del></li>
          <li class="del"><del>zzz_ddd_2    : 2</del></li>
          <li class="del"><del>zzz_ddd_3    : 1</del></li>
          <li class="del"><del>zzz_eee_aa   : 123</del></li>
          <li class="del"><del>zzz_eee_bb   : 21.3</del></li>
          <li class="del"><del>zzz_eee_dd   : 2020-05-04</del></li>
          <li class="del"><del>zzz_eee_ff   : aaa</del></li>
          <li class="del"><del>zzz_ggg_1_a  : 1</del></li>
          <li class="del"><del>zzz_ggg_1_b  : 3</del></li>
          <li class="del"><del>zzz_ggg_1_d  : 2</del></li>
          <li class="del"><del>zzz_ggg_2_a  : 2</del></li>
          <li class="del"><del>zzz_ggg_2_b  : 6</del></li>
          <li class="del"><del>zzz_ggg_2_d  : 4</del></li>
        </ul>
      </div>
    STR

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    renderer = Crossbeams::Layout::Diff.new(page_config, :test_field)

    # puts renderer.render
    # puts left_str
    assert renderer.render.include?(left_str)
  end

  def test_nested_record_unsorted
    left_rec = {
      zzz: {
        ddd: [3,2,1],
        ggg: [{a: 1, d: 2, b: 3}, {a: 2, d: 4, b: 6}],
        eee: {
          ff: 'aaa',
          dd: Date.new(2020, 5, 4),
          aa: 123,
          bb: BigDecimal.new('21.3')
        },
        ccc: 'aaa'
      },
      aaa: 'aa'
    }
    right_rec = {}

    fields = { test_field: {
          left_caption: 'Before',
          right_caption: 'After',
          left_record: left_rec,
          right_record: right_rec,
          unnest_records: true,
          sort_nested: false
    }}
    left_str = <<~STR
        <ul>
          <li class="del"><del>zzz_ddd_1    : 3</del></li>
          <li class="del"><del>zzz_ddd_2    : 2</del></li>
          <li class="del"><del>zzz_ddd_3    : 1</del></li>
          <li class="del"><del>zzz_ggg_1_a  : 1</del></li>
          <li class="del"><del>zzz_ggg_1_d  : 2</del></li>
          <li class="del"><del>zzz_ggg_1_b  : 3</del></li>
          <li class="del"><del>zzz_ggg_2_a  : 2</del></li>
          <li class="del"><del>zzz_ggg_2_d  : 4</del></li>
          <li class="del"><del>zzz_ggg_2_b  : 6</del></li>
          <li class="del"><del>zzz_eee_ff   : aaa</del></li>
          <li class="del"><del>zzz_eee_dd   : 2020-05-04</del></li>
          <li class="del"><del>zzz_eee_aa   : 123</del></li>
          <li class="del"><del>zzz_eee_bb   : 21.3</del></li>
          <li class="del"><del>zzz_ccc      : aaa</del></li>
          <li class="del"><del>aaa          : aa</del></li>
        </ul>
      </div>
    STR

    page_config = Crossbeams::Layout::PageConfig.new({ name: 'test_form', form_object: OpenStruct.new(test_field: nil), fields: fields })
    renderer = Crossbeams::Layout::Diff.new(page_config, :test_field)

    # puts renderer.render
    # puts left_str
    assert renderer.render.include?(left_str)
  end
end
