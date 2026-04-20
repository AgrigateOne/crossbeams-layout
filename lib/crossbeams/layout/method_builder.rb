# frozen_string_literal: true

module Crossbeams
  module Layout
    # Define common methods for layout classes
    module MethodBuilder
      def build_methods_for(*node_names) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        node_names.each do |node_name| # rubocop:disable Metrics/BlockLength
          case node_name
          when :table
            define_method(:add_table) do |rows, columns, options = {}|
              @nodes << Table.new(page_config, rows, columns, options)
            end
          when :fold_up
            define_method(:fold_up) do |&blk|
              fold_up = FoldUp.new(page_config, nodes.length + 1)
              blk.call(fold_up)
              @nodes << fold_up
            end
          when :csrf
            define_method(:add_csrf_tag) do |tag|
              @nodes.each { |node| node.add_csrf_tag(tag) if node.respond_to?(:add_csrf_tag) }
            end
          when :row
            define_method(:row) do |&blk|
              row = Row.new(page_config, sequence, nodes.length + 1)
              blk.call(row)
              @nodes << row
            end
          when :text
            define_method(:add_text) do |text, options = {}|
              @nodes << Text.new(page_config, text, options)
            end
          when :notice
            define_method(:add_notice) do |text, options = {}|
              @nodes << Notice.new(page_config, text, options)
            end
          when :diff
            define_method(:add_diff) do |key|
              @nodes << Diff.new(page_config, key)
            end
          when :list
            define_method(:add_list) do |items, options = {}|
              @nodes << List.new(page_config, items, options)
            end
          when :sortable_list
            define_method(:add_sortable_list) do |prefix, items, options = {}|
              @nodes << SortableList.new(page_config, prefix, items, options)
            end
          when :repeating_request
            define_method(:add_repeating_request) do |url, interval, content, options = {}|
              @nodes << RepeatingRequest.new(page_config, url, interval, content, options)
            end
          when :tab_set
            define_method(:add_tab_set) do |items, options = {}|
              @nodes << TabSet.new(page_config, items, options)
            end
          when :address
            define_method(:add_address) do |addresses, options = {}|
              @nodes << Address.new(page_config, addresses, options)
            end
          when :contact_method
            define_method(:add_contact_method) do |contact_methods, options = {}|
              @nodes << ContactMethod.new(page_config, contact_methods, options)
            end
          when :grid
            define_method(:add_grid) do |grid_id, url, options = {}|
              @nodes << if instance_variable_defined?(:@fit_height)
                          Grid.new(page_config, grid_id, url, options.merge(fit_height: @fit_height))
                        else
                          Grid.new(page_config, grid_id, url, options)
                        end
            end
          when :chart
            define_method(:add_chart) do |spec, options = {}|
              @nodes << Chart.new(page_config, spec, options)
            end
          when :bar_chart
            define_method(:add_bar_chart) do |data, x_field:, y_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.bar_chart(data, x_field: x_field, y_field: y_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :line_chart
            define_method(:add_line_chart) do |data, x_field:, y_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.line_chart(data, x_field: x_field, y_field: y_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :pie_chart
            define_method(:add_pie_chart) do |data, value_field:, category_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.pie_chart(data, value_field: value_field, category_field: category_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :donut_chart
            define_method(:add_donut_chart) do |data, value_field:, category_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.donut_chart(data, value_field: value_field, category_field: category_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :area_chart
            define_method(:add_area_chart) do |data, x_field:, y_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.area_chart(data, x_field: x_field, y_field: y_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :scatter_chart
            define_method(:add_scatter_chart) do |data, x_field:, y_field:, **options|
              chart_opts = Chart.extract_options(options)
              spec_opts = Chart.extract_spec_options(options)
              spec = ChartTypes.scatter_chart(data, x_field: x_field, y_field: y_field, **spec_opts)
              @nodes << Chart.new(page_config, spec, chart_opts)
            end
          when :kpi_cards
            define_method(:add_kpi_cards) do |items, **options|
              @nodes << KpiCards.new(page_config, items, options)
            end
            define_method(:add_kpi_card) do |label:, value:, **options|
              item = { label: label, value: value }.merge(options.slice(:subtitle, :tone, :icon))
              card_options = options.except(:subtitle, :tone, :icon)
              @nodes << KpiCards.new(page_config, [item], card_options)
            end
          when :section
            define_method(:section) do |&blk|
              section = Section.new(page_config, nodes.length + 1)
              blk.call(section)
              @nodes << section
            end
          # Add a group that will render its children in a horizontal row
          when :horizontal_group
            define_method(:horizontal_group) do |&blk|
              group = HorizontalGroup.new(page_config, nodes.length + 1)
              blk.call(group)
              @nodes << group
            end
          when :collection
            define_method(:collection) do |&blk|
              collection = Collection.new
              blk.call(collection)
              @nodes << collection
            end
          else
            raise ArgumentError, "#{node_name} is not a valid option for `build_methods_for`"
          end
        end
      end
    end
  end
end
