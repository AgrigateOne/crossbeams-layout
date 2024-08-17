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
            define_method(:add_text) do |text, opts = {}|
              @nodes << Text.new(page_config, text, opts)
            end
          when :notice
            define_method(:add_notice) do |text, opts = {}|
              @nodes << Notice.new(page_config, text, opts)
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
            define_method(:add_repeating_request) do |url, interval, content|
              @nodes << RepeatingRequest.new(page_config, url, interval, content)
            end
          when :address
            define_method(:add_address) do |addresses, opts = {}|
              @nodes << Address.new(page_config, addresses, opts)
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
          when :section
            define_method(:section) do |&blk|
              section = Section.new(page_config, nodes.length + 1)
              blk.call(section)
              @nodes << section
            end
          else
            raise ArgumentError, "#{node_name} is not a valid option for `build_methods_for`"
          end
        end
      end
    end
  end
end
