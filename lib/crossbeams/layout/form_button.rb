# frozen_string_literal: true

module Crossbeams
  module Layout
    # Button for a form to be rendered with a form's submit input
    class FormButton
      attr_reader :btn_name, :caption, :formaction, :remote, :disable_with, :dom_id, :disabled

      SC = StylesConfig

      def initialize(caption, formaction, options = {})
        @caption = caption
        @formaction = formaction
        @remote = options[:remote].nil? ? nil : options[:remote]
        @disable_with = options[:disable_with] || 'Submitting...'
        @bg_colour = options[:colour]
        @dom_id = options[:dom_id]
        @btn_name = options[:name] || 'commit'
        @disabled = options[:disabled]
      end

      def render(remote_form)
        render_remote = remote.nil? ? remote_form : remote
        remote_str = render_remote ? ' data-remote="true"' : ''
        disabler = render_remote ? 'briefly-disable' : 'disable'
        <<~HTML
          <button#{render_id}#{render_name} formaction="#{formaction}" type="submit"#{remote_str} data-#{disabler}-with="#{disable_with}" class="#{btn_class}"#{render_disable}>
            #{caption}
          </button>
        HTML
      end

      private

      def btn_class
        if @bg_colour
          SC.css_class(:button_secondary).sub("bg-#{SC.css_class(:secondary_bg)}", bg_colour)
        else
          SC.css_class(:button_secondary)
        end
      end

      def bg_colour
        case @bg_colour
        when nil, :standard
          "bg-#{SC.css_class(:secondary_bg)}"
        when :green
          SC.css_class(:bg_green)
        when :amber
          SC.css_class(:bg_amber)
        when :red
          SC.css_class(:bg_red)
        when :blue
          SC.css_class(:bg_blue)
        else
          raise ArgumentError, "Invalid button colour - #{@bg_colour}"
        end
      end

      def render_id
        return '' unless dom_id

        %( id="#{dom_id}")
      end

      def render_name
        return '' unless btn_name

        %( name="#{btn_name}")
      end

      def render_disable
        return '' unless disabled

        ' disabled="true"'
      end
    end
  end
end
