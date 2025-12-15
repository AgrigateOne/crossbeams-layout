# frozen_string_literal: true

module Crossbeams
  module Layout
    # Field object which is rendered by a specific field renderer.
    class Field
      attr_reader :name, :caption, :page_config

      def initialize(page_config, name, options = {})
        @name        = name
        @caption     = options[:caption] || name # is this used at all????
        @page_config = page_config
        raise ArgumentError, %(There is no renderer defined for "#{@name}") if field_config.nil?
      end

      def invisible?
        field_config[:invisible]
      end

      def hidden?
        field_config[:renderer] == :hidden
      end

      def field_has_errors? # rubocop:disable Metrics/AbcSize
        return false unless page_config.form_errors

        has_err = if field_config[:parent_field]
                    (page_config.form_errors[field_config[:parent_field]] || {})[name]
                  else
                    page_config.form_errors[name]
                  end
        !has_err.nil?
      end

      def render
        renderer = Renderer::FieldFactory.new(name, field_config, page_config)
        renderer.render
      end

      private

      def field_config
        (page_config.options[:fields] || {})[name]
      end
    end
  end
end
