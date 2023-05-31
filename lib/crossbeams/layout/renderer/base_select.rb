# frozen_string_literal: true

module Crossbeams
  module Layout
    module Renderer
      # Base class for all select field renderers.
      class BaseSelect < Base # rubocop:disable Metrics/ClassLength
        private

        def optgroup?(options, disabled_options)
          options.is_a?(Hash) || disabled_options.is_a?(Hash)
        end

        def using_2d_options?(options, disabled_options)
          return true if options.is_a?(Hash) || disabled_options.is_a?(Hash)

          if options.empty?
            disabled_options.first.is_a?(Array)
          else
            options.first.is_a?(Array)
          end
        end

        def prepare_selected
          sel = Array(@field_config[:selected] || form_object_value)

          @selected_options = Array(override_with_form_value(sel)).reject { |v| v.to_s.empty? }.map(&:to_s)
        end

        def prepare_options # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          if @optgroup
            @options = (@field_config[:options] || {}).transform_values { |v| v.map { |text, value| [text.to_s, value.to_s] } }
            return
          end

          @options = if @options_2d
                       (@field_config[:options] || []).map { |text, value| [text.to_s, value.to_s] }
                     else
                       (@field_config[:options] || []).map(&:to_s)
                     end
        end

        def prepare_disabled # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          disabled = if @optgroup
                       (@field_config[:disabled_options] || {}).transform_values { |v| v.map { |text, value| [text.to_s, value.to_s] } }
                     elsif @options_2d
                       (@field_config[:disabled_options] || []).map { |text, value| [text.to_s, value.to_s] }
                     else
                       (@field_config[:disabled_options] || []).map(&:to_s)
                     end

          @disabled_options = if @optgroup
                                make_disabled_optgroup_list(@selected_options, @options, disabled)
                              elsif @options_2d
                                make_disabled_2d_list(@selected_options, @options, disabled)
                              else
                                make_disabled_list(@selected_options, @options, disabled)
                              end
        end

        def make_disabled_optgroup_list(selected, options, disabled_options) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          grp = {}
          selected.each do |sel|
            found = false
            disabled_options.each do |group, values|
              opt = values.rassoc(sel)
              next unless opt

              found = true
              grp[group] ||= []
              grp[group] << opt
            end
            next if found

            options.each do |group, values|
              opt = values.rassoc(sel)
              next unless opt

              grp[group] ||= []
              grp[group] << opt
            end
          end
          grp
        end

        def make_disabled_2d_list(selected, options, disabled_options)
          ar = []
          selected.each do |sel|
            opt = disabled_options.rassoc(sel)
            if opt
              ar << opt
            elsif !options.find { |_, v| v == sel }
              raise Crossbeams::Layout::Error, "#{self.class}: The value \"#{sel}\" is not present in options or disabled options."
            end
          end
          ar
        end

        def make_disabled_list(selected, options, disabled_options)
          ar = []
          selected.each do |sel|
            if disabled_options.include?(sel)
              ar << sel
            elsif !options.include?(sel)
              raise Crossbeams::Layout::Error, "#{self.class}: The value \"#{sel}\" is not present in options or disabled options."
            end
          end
          ar
        end

        def build_1_or_2_options
          if @optgroup
            build_optgroup_options(@options, @selected_options, @disabled_options)
          elsif @options_2d
            build_2d_options(@options, @selected_options, @disabled_options)
          else
            build_1d_options(@options, @selected_options, @disabled_options)
          end
        end

        def build_1d_options(list, selected = [], disabled = [])
          opts = list.map do |value|
            sel = selected.include?(value) ? ' selected' : ''
            dis = disabled.include?(sel) ? ' disabled' : ''
            "<option value=\"#{CGI.escapeHTML(value)}\"#{sel}#{dis}>#{CGI.escapeHTML(value)}</option>"
          end

          disabled.each do |value|
            sel = selected.include?(value) ? ' selected' : ''
            opts.unshift("<option value=\"#{CGI.escapeHTML(value)}\"#{sel} disabled>#{CGI.escapeHTML(value)}</option>")
          end
          opts.join("\n")
        end

        def build_optgroup_options(list, selected = [], disabled = {})
          opts = []
          list.each do |group, sublist|
            opts << %(<optgroup label="#{group}">)
            opts << build_2d_options(sublist, selected, disabled[group] || [])
            opts << '</optgroup>'
          end
          opts.join("\n")
        end

        def build_2d_options(list, selected = [], disabled = [])
          opts = list.map do |text, value|
            sel = selected.include?(value) ? ' selected ' : ''
            "<option value=\"#{CGI.escapeHTML(value)}\"#{sel}#{disabled}>#{CGI.escapeHTML(text)}</option>"
          end

          disabled.each do |text, value|
            opts.unshift("<option value=\"#{CGI.escapeHTML(value)}\" selected disabled>#{CGI.escapeHTML(text)}</option>")
          end
          opts.join("\n")
        end
      end
    end
  end
end
