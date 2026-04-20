# frozen_string_literal: true

module Crossbeams
  module Layout
    # Render KPI (Key Performance Indicator) cards in a responsive grid.
    #
    # KPI cards display metric values with labels, optional subtitles,
    # and visual tone indicators for dashboards and summary views.
    #
    # == Usage
    #
    #   section.add_kpi_cards([
    #     { label: 'Total Sales', value: 82_450 },
    #     { label: 'Orders', value: 1_234, subtitle: 'Last 30 days' },
    #     { label: 'Returns', value: 45, tone: :warning }
    #   ])
    #
    class KpiCards
      SC = StylesConfig

      VALID_TONES = %i[default info success warning danger].freeze
      DEFAULT_COLUMNS = { sm: 2, md: 3, lg: 6 }.freeze

      attr_reader :items, :options, :page_config

      def initialize(page_config, items, options = {})
        @page_config = page_config
        @options = options

        validate_items_type!(items)
        @items = normalize_items(items)
        validate_item_contents!
      end

      # Is this node invisible?
      #
      # @return [boolean]
      def invisible?
        items.empty?
      end

      # Is this node hidden?
      #
      # @return [boolean]
      def hidden?
        false
      end

      # Render this node as HTML.
      #
      # @return [String]
      def render
        return '' if invisible?

        <<~HTML
          <div class="#{wrapper_classes}">
            #{render_cards}
          </div>
        HTML
      end

      private

      def validate_items_type!(items)
        return if items.nil?
        raise ArgumentError, 'KpiCards: items must be an array' unless items.is_a?(Array)

        items.each_with_index do |item, index|
          raise ArgumentError, "KpiCards: item at index #{index} must be a hash" unless item.is_a?(Hash)
        end
      end

      def validate_item_contents!
        @items.each_with_index do |item, index|
          raise ArgumentError, "KpiCards: item at index #{index} is missing required key :label" unless item.key?(:label)
          raise ArgumentError, "KpiCards: item at index #{index} is missing required key :value" unless item.key?(:value)

          if item[:tone] && !VALID_TONES.include?(item[:tone])
            raise ArgumentError, "KpiCards: item at index #{index} has invalid tone '#{item[:tone]}'. Valid tones: #{VALID_TONES.join(', ')}"
          end
        end
      end

      def normalize_items(raw_items)
        return [] if raw_items.nil?

        raw_items.map do |item|
          item.transform_keys(&:to_sym)
        end
      end

      def wrapper_classes
        base = SC.css_class(:kpi_cards_wrapper)
        columns = options[:columns] || DEFAULT_COLUMNS
        grid_cols = build_grid_columns(columns)
        gap = options[:gap] || 'gap-4'
        extra = options[:wrapper_class] || ''

        [base, grid_cols, gap, extra].reject(&:empty?).join(' ')
      end

      def build_grid_columns(columns)
        if columns.is_a?(Hash)
          sm = columns[:sm] || 2
          md = columns[:md] || 3
          lg = columns[:lg] || 6
          "grid grid-cols-#{sm} md:grid-cols-#{md} lg:grid-cols-#{lg}"
        else
          "grid grid-cols-#{columns}"
        end
      end

      def render_cards
        items.map { |item| render_card(item) }.join("\n")
      end

      def render_card(item)
        tone = item[:tone] || :default
        card_class = build_card_class(tone)
        icon_html = render_icon(item[:icon]) if item[:icon]

        <<~HTML
          <div class="#{card_class}">
            #{icon_html}
            <div class="#{label_classes}">#{item[:label]}</div>
            <div class="#{value_classes(tone)}">#{format_value(item)}</div>
            #{render_subtitle(item[:subtitle]) if item[:subtitle]}
          </div>
        HTML
      end

      def build_card_class(tone)
        base = SC.css_class(:kpi_card)
        tone_class = tone_card_class(tone)
        extra = options[:card_class] || ''

        [base, tone_class, extra].reject(&:empty?).join(' ')
      end

      def tone_card_class(tone)
        case tone
        when :info
          SC.css_class(:kpi_card_info)
        when :success
          SC.css_class(:kpi_card_success)
        when :warning
          SC.css_class(:kpi_card_warning)
        when :danger
          SC.css_class(:kpi_card_danger)
        else
          ''
        end
      end

      def label_classes
        options[:label_class] || SC.css_class(:kpi_label)
      end

      def value_classes(tone)
        base = options[:value_class] || SC.css_class(:kpi_value)
        tone_value = tone_value_class(tone)

        [base, tone_value].reject(&:empty?).join(' ')
      end

      def tone_value_class(tone)
        case tone
        when :info
          SC.css_class(:kpi_value_info)
        when :success
          SC.css_class(:kpi_value_success)
        when :warning
          SC.css_class(:kpi_value_warning)
        when :danger
          SC.css_class(:kpi_value_danger)
        else
          ''
        end
      end

      def render_subtitle(subtitle)
        subtitle_class = options[:subtitle_class] || SC.css_class(:kpi_subtitle)
        %(<div class="#{subtitle_class}">#{subtitle}</div>)
      end

      def render_icon(icon_name)
        Icon.render(icon_name, css_class: SC.css_class(:kpi_icon))
      end

      def format_value(item)
        value = item[:value]
        formatter = options[:value_formatter]

        if formatter.respond_to?(:call)
          formatter.call(value, item)
        else
          value.to_s
        end
      end
    end
  end
end
