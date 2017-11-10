# frozen_string_literal: true

module Crossbeams
  module Layout
    # Display one or more contact methods
    class ContactMethod
      include PageNode
      attr_reader :contact_methods, :lookup_icon

      def initialize(page_config, contact_methods, options = {})
        @page_config     = page_config
        @nodes           = []
        @contact_methods = Array(contact_methods)
        @lookup_icon     = {
          'tel'   => 'tel',
          'cell'  => 'cell',
          'fax'   => 'fax',
          'email' => 'email'
        }
        (options[:icon_lookups] || {}).each do |method_type, icon|
          @lookup_icon[method_type.to_s.downcase] = icon
        end
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
        @contact_methods.map { |contact_method| render_contact_method(contact_method) }.join("\n")
      end

      private

      def render_contact_method(contact_method)
        <<~HTML
        <div class="center mw5 mw6-ns hidden ba mv3">
          <h1 class="f4 bg-light-purple white mv0 pv2 ph3" style="text-transform:lowercase"><i class="fa #{icon(contact_method)}" style="margin-right:0.5em"></i>#{contact_method.contact_method_type}</h1>
          <div class="f6 f5-ns lh-copy measure mv0 pa2">#{contact_method.contact_method_code}
          </div>
          </div>
        HTML
      end

      def icon(contact_method)
        case lookup_icon[contact_method.contact_method_type.downcase]
        when 'tel'
          'fa-phone'
        when 'cell'
          'fa-mobile'
        when 'fax'
          'fa-fax'
        when 'social'
          'fa-at'
        else
          'fa-asterisk'
        end
      end
    end
  end
end

