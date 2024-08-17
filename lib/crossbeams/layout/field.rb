# frozen_string_literal: true

module Crossbeams
  module Layout
    # Field object which is rendered by a specific field renderer.
    class Field
      attr_reader :name, :caption, :page_config

      def initialize(page_config, name, options = {})
        @name        = name
        @caption     = options[:caption] || name
        @page_config = page_config
        raise ArgumentError, "There is no renderer defined for #{@name}" if field_config.nil?
      end

      def invisible?
        field_config[:invisible]
      end

      def hidden?
        field_config[:renderer] == :hidden
      end

      def render
        # Needs another pass of config to resolve if we're doing a view/edit etc.
        renderer = Renderer::FieldFactory.new(name, field_config, page_config)
        # renderer.configure(page_config)
        renderer.render
      end

      private

      def field_config
        (page_config.options[:fields] || {})[name]
      end
    end
  end
end
