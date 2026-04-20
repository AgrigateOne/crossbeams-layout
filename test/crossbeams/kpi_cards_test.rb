# frozen_string_literal: true

require 'test_helper'

class Crossbeams::KpiCardsTest < Minitest::Test
  def page_config
    Crossbeams::Layout::PageConfig.new({})
  end

  def sample_items
    [
      { label: 'Total Sales', value: 82_450 },
      { label: 'Orders', value: 1234 },
      { label: 'Revenue', value: '$45,000' }
    ]
  end

  # Basic rendering tests

  def test_renders_wrapper_div
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items)
    html = cards.render

    assert_includes html, 'grid'
    assert_includes html, 'grid-cols-2'
    assert_includes html, 'md:grid-cols-3'
    assert_includes html, 'lg:grid-cols-6'
  end

  def test_renders_all_cards
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items)
    html = cards.render

    assert_includes html, 'Total Sales'
    assert_includes html, '82450'
    assert_includes html, 'Orders'
    assert_includes html, '1234'
    assert_includes html, 'Revenue'
    assert_includes html, '$45,000'
  end

  def test_renders_default_classes
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items)
    html = cards.render

    assert_includes html, 'bg-white'
    assert_includes html, 'rounded-lg'
    assert_includes html, 'shadow-sm'
    assert_includes html, 'uppercase'
    assert_includes html, 'tracking-wide'
    assert_includes html, 'font-semibold'
  end

  def test_invisible_when_empty
    cards = Crossbeams::Layout::KpiCards.new(page_config, [])

    assert cards.invisible?
    assert_equal '', cards.render
  end

  def test_not_invisible_with_items
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items)

    refute cards.invisible?
  end

  def test_hidden_returns_false
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items)

    refute cards.hidden?
  end

  # Custom options tests

  def test_custom_columns_hash
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, columns: { sm: 1, md: 2, lg: 4 })
    html = cards.render

    assert_includes html, 'grid-cols-1'
    assert_includes html, 'md:grid-cols-2'
    assert_includes html, 'lg:grid-cols-4'
  end

  def test_custom_columns_integer
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, columns: 3)
    html = cards.render

    assert_includes html, 'grid-cols-3'
  end

  def test_custom_gap
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, gap: 'gap-6')
    html = cards.render

    assert_includes html, 'gap-6'
  end

  def test_custom_wrapper_class
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, wrapper_class: 'my-custom-wrapper')
    html = cards.render

    assert_includes html, 'my-custom-wrapper'
  end

  def test_custom_card_class
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, card_class: 'my-custom-card')
    html = cards.render

    assert_includes html, 'my-custom-card'
  end

  def test_custom_label_class
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, label_class: 'my-label-class')
    html = cards.render

    assert_includes html, 'my-label-class'
  end

  def test_custom_value_class
    cards = Crossbeams::Layout::KpiCards.new(page_config, sample_items, value_class: 'my-value-class')
    html = cards.render

    assert_includes html, 'my-value-class'
  end

  # Value formatter tests

  def test_value_formatter_lambda
    items = [{ label: 'Price', value: 1234.567 }]
    formatter = ->(val, _item) { format('$%.2f', val) }
    cards = Crossbeams::Layout::KpiCards.new(page_config, items, value_formatter: formatter)
    html = cards.render

    assert_includes html, '$1234.57'
  end

  def test_value_formatter_with_item_context
    items = [
      { label: 'Count', value: 100 },
      { label: 'Average', value: 33.333 }
    ]
    formatter = lambda do |val, item|
      item[:label] == 'Average' ? format('%.1f', val) : val.to_s
    end
    cards = Crossbeams::Layout::KpiCards.new(page_config, items, value_formatter: formatter)
    html = cards.render

    assert_includes html, '>100<'
    assert_includes html, '>33.3<'
  end

  # Tone tests

  def test_tone_default
    items = [{ label: 'Test', value: 1 }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    refute_includes html, 'border-l-4'
  end

  def test_tone_info
    items = [{ label: 'Test', value: 1, tone: :info }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'border-l-sky-500'
    assert_includes html, 'text-sky-700'
  end

  def test_tone_success
    items = [{ label: 'Test', value: 1, tone: :success }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'border-l-green-500'
    assert_includes html, 'text-green-700'
  end

  def test_tone_warning
    items = [{ label: 'Test', value: 1, tone: :warning }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'border-l-amber-500'
    assert_includes html, 'text-amber-700'
  end

  def test_tone_danger
    items = [{ label: 'Test', value: 1, tone: :danger }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'border-l-red-500'
    assert_includes html, 'text-red-700'
  end

  # Subtitle tests

  def test_renders_subtitle
    items = [{ label: 'Test', value: 1, subtitle: 'Last 30 days' }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'Last 30 days'
  end

  def test_custom_subtitle_class
    items = [{ label: 'Test', value: 1, subtitle: 'Subtext' }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items, subtitle_class: 'my-subtitle')
    html = cards.render

    assert_includes html, 'my-subtitle'
    assert_includes html, 'Subtext'
  end

  def test_no_subtitle_div_when_not_provided
    items = [{ label: 'Test', value: 1 }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    refute_match(/class="[^"]*kpi_subtitle/, html)
  end

  # Validation tests

  def test_raises_when_items_not_array
    assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, 'not an array')
    end
  end

  def test_raises_when_item_not_hash
    assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, ['not a hash'])
    end
  end

  def test_raises_when_missing_label
    assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, [{ value: 1 }])
    end
  end

  def test_raises_when_missing_value
    assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, [{ label: 'Test' }])
    end
  end

  def test_raises_for_invalid_tone
    assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, [{ label: 'Test', value: 1, tone: :invalid }])
    end
  end

  def test_error_message_includes_index
    error = assert_raises(ArgumentError) do
      Crossbeams::Layout::KpiCards.new(page_config, [{ label: 'OK', value: 1 }, { label: 'Bad' }])
    end

    assert_includes error.message, 'index 1'
  end

  # String keys normalization

  def test_accepts_string_keys
    items = [{ 'label' => 'Test', 'value' => 123, 'subtitle' => 'Note' }]
    cards = Crossbeams::Layout::KpiCards.new(page_config, items)
    html = cards.render

    assert_includes html, 'Test'
    assert_includes html, '123'
    assert_includes html, 'Note'
  end

  # DSL integration tests

  def test_page_add_kpi_cards
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_kpi_cards(sample_items)
    end

    html = page.render
    assert_includes html, 'Total Sales'
    assert_includes html, '82450'
  end

  def test_section_add_kpi_cards
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.section do |section|
        section.add_kpi_cards(sample_items)
      end
    end

    html = page.render
    assert_includes html, 'Total Sales'
  end

  def test_add_kpi_card_single
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_kpi_card(label: 'Single KPI', value: 999, subtitle: 'Today')
    end

    html = page.render
    assert_includes html, 'Single KPI'
    assert_includes html, '999'
    assert_includes html, 'Today'
  end

  def test_add_kpi_card_with_tone
    page = Crossbeams::Layout::Page.build do |p, _config|
      p.add_kpi_card(label: 'Alert', value: 5, tone: :danger)
    end

    html = page.render
    assert_includes html, 'Alert'
    assert_includes html, 'border-l-red-500'
  end

  # Handles nil items gracefully

  def test_handles_nil_items
    cards = Crossbeams::Layout::KpiCards.new(page_config, nil)

    assert cards.invisible?
    assert_equal '', cards.render
  end
end
