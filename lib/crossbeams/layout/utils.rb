# frozen_string_literal: true

module Crossbeams
  module Layout
    # Utility functions for use in layouts outside of the Page tree.
    class Utils
      ELEMENTS = %i[h1 h2 h3 h4 em strong ul ol li].freeze
      ELEM_CLASSES = ELEMENTS.map { |k| ["<#{k}>", %(<#{k} class="#{Crossbeams::Layout::StylesConfig.config.send(k)}">)] }.to_h
      REGEX_KEY = /<#{ELEMENTS.join('>|<')}>/.freeze

      # Take an HTML string and add styling classes to plain dom elements
      #
      # e.g. <h1>Some Text</h1> becomes something like:
      #      <h1 class="text-2xl">Some Text</h1>
      #
      # @param html [string] the input HTML string
      # @return [string]
      def self.classify_dom_elements(html)
        html.gsub(REGEX_KEY, ELEM_CLASSES)
      end

      def self.crossbeams_field_classes(restrict_width: true)
        max = ' max-w-96' if restrict_width
        "min-w-22 mb-2#{max}"
      end
    end
  end
end
