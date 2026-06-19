# frozen_string_literal: true

module Crossbeams
  module Layout
    # A Filter that contains fields
    class FilterField < Renderer::BaseSelect
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf

      attr_reader :field_name, :caption

      def initialize(field_name, options = {}) # rubocop:disable Metrics/AbcSize
        @page_config = OpenStruct.new({ name: 'cbl_filter', form_object: OpenStruct.new(field_name => nil) }) # incl. form_object with selected values...
        @field_name = field_name
        @field_config = { options: options[:items], selected: options.fetch(:selected, []) || [], disabled_options: nil }
        @caption = options[:caption] || field_name.to_s.delete_suffix('_id').gsub('_', ' ').capitalize
        @optgroup = optgroup?(@field_config[:options], @field_config[:disabled_options])
        @options_2d = using_2d_options?(@field_config[:options], @field_config[:disabled_options])
        prepare_selected
        prepare_options
        prepare_disabled
        super()
        # @caption = options.fetch(:caption, field_name.to_s.capitalize.gsub('_', ' '))
        @nodes = []
        # @items = options[:items]
        # @selected = options[:selected] || []
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        # swap inline-flex  for hidden to show...
        attrs = [%(class="w-full searchable-multi-select")]
        #   #{backup_empty_select}
        <<~HTML
          <div class="relative">
            <div id="filter_field_#{field_name}" data-filter-wrapper="Y" class="border border-slate-600 rounded-full p-2 flex items-center">
              <label class="" data-filter-field="Y">#{caption}</label>
              <div class="inline-flex" data-filter-label-val="Y">#{selected_values(prefix: true)}</div>
            </div>
            <div class="hidden absolute min-w-96" data-filter-lookup="Y">
              <select #{attrs.join(' ')} #{name_attribute_multi} #{field_id} data-filter-select="Y" multiple>
              #{build_1_or_2_options}
              </select>
            </div>
          </div>
        HTML
      end

      def backup_empty_select
        # Hidden blank value to be submitted as a param if the Searchable component box is cleared.
        %(<input #{name_attribute_multi} type="hidden" value="">)
      end

      def selected_params
        return nil if @field_config[:selected].empty?

        # Return nil if no params selected, or an array of field_name and an array of selected values
        [field_name, @field_config[:selected]]
      end

      def selected_param_texts
        return nil if @field_config[:selected].empty?

        # Return nil if no params selected, or a string with the caption and the selected display values
        "#{caption}: #{selected_values}"
      end

      private

      def show_caption
        return caption if @field_config[:selected].empty?

        "#{caption} | #{selected_values}"
      end

      def selected_values(prefix: false) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        items = @field_config[:options].select do |item|
          if item.is_a?(Array)
            @field_config[:selected].include?(item.last.to_s) # OR make the input the correct type?
          else
            @field_config[:selected].include?(item.to_s)
          end
        end
        return '' if items.empty?

        if prefix
          %(<span class="px-1">| #{items.map { |i| i.is_a?(Array) ? i.first : i }.join(', ')}</span>)
        else
          items.map { |i| i.is_a?(Array) ? i.first : i }.join(', ')
        end
      end
    end
  end
end
