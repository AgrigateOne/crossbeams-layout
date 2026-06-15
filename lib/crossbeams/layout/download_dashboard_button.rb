# frozen_string_literal: true

module Crossbeams
  module Layout
    # A button renderer that sets attributes for downloading a PDF version of a dashboard
    class DownloadDashboardButton
      extend MethodBuilder

      SC = StylesConfig

      build_methods_for :csrf
      attr_reader :text, :title, :tabset_id, :filter_id

      def initialize(options = {})
        @text = options.fetch(:text, 'Download PDF')
        @title = options[:title]
        @tabset_id = options[:tabset_id]
        @filer_id = options[:filer_id]
        @nodes = []
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

      # Render this node as an HTML button with attributes to direct the PDF download.
      #
      # @return [string] - HTML representation of this node.
      def render
        <<-HTML
          <button type="button" class="inline-block #{SC.css_class(:button_secondary)}" data-download-dashboard="Y" data-title="#{title}" data-tabset="#{tabset_id}" data-filter="#{filter_id}">
            #{Icon.new(:download, css_class: 'align-middle inline-block').render} #{text}
          </button>
        HTML
      end
    end
  end
end
