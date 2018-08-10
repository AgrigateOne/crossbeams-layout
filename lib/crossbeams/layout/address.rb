# frozen_string_literal: true

module Crossbeams
  module Layout
    # Display an address
    class Address
      include PageNode
      attr_reader :include_type, :addresses

      def initialize(page_config, addresses, options = {})
        @page_config  = page_config
        @nodes        = []
        @addresses    = Array(addresses)
        @include_type = options.fetch(:include_address_type) { true }
      end

      # Is this node invisible?
      #
      # @return [boolean] - true if it should not be rendered at all, else false.
      def invisible?
        false
      end

      # Is this node hidden?
      #
      # @return [boolean] - true if it should be rendered as hidden, else false.
      def hidden?
        false
      end

      # Render this node as HTML link.
      #
      # @return [string] - HTML representation of this node.
      def render
        @addresses.map { |address| render_address(address.to_h) }.join("\n")
      end

      private

      def render_address(address)
        <<~HTML
          <div class="center mw5 mw6-ns hidden ba mv4">
            <h1 class="f4 bg-dark-blue white mv0 pv2 ph3" style="text-transform:lowercase">#{address_icon}#{render_address_type(address)}</h1>
            <address class="f6 f5-ns lh-copy measure mv0 pa2">
              #{combined_address_lines(address)}<br>
              #{city_and_code(address)}<br>
              #{address[:country]}
            </address>
          </div>
        HTML
      end

      def address_icon
        Icon.render(:envelope, css_class: 'mr1')
      end

      def combined_address_lines(address)
        %i[address_line_1 address_line_2 address_line_3].map do |line|
          address[line]
        end.compact.join('<br>')
      end

      def city_and_code(address)
        %i[city postal_code].map do |code|
          address[code]
        end.compact.join(', ')
      end

      def render_address_type(address)
        return '' if !@include_type || !address.key?(:address_type)
        "#{address[:address_type]}<br>"
      end
    end
  end
end
