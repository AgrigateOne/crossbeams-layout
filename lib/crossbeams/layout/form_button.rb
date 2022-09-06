# frozen_string_literal: true

module Crossbeams
  module Layout
    # Button for a form to be rendered with a form's submit input
    class FormButton
      attr_reader :btn_name, :caption, :formaction, :remote, :disable_with, :bg_colour, :dom_id, :disabled

      def initialize(caption, formaction, options = {})
        @caption = caption
        @formaction = formaction
        @remote = options[:remote].nil? ? nil : options[:remote]
        @disable_with = options[:disable_with] || 'Submitting...'
        @bg_colour = "bg-#{options[:colour] || 'gray'}"
        @dom_id = options[:dom_id]
        @btn_name = options[:name] || 'commit'
        @disabled = options[:disabled]
      end

      def render(remote_form)
        render_remote = remote.nil? ? remote_form : remote
        remote_str = render_remote ? ' data-remote="true"' : ''
        disabler = render_remote ? 'briefly-disable' : 'disable'
        <<~HTML
          <button#{render_id}#{render_name} formaction="#{formaction}" type="submit"#{remote_str} data-#{disabler}-with="#{disable_with}" class="dim br2 ml2 mb2 pa3 bn white #{bg_colour} mr3"#{render_disable}>
            #{caption}
          </button>
        HTML
      end

      private

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

