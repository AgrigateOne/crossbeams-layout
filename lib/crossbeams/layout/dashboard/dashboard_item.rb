# frozen_string_literal: true

module Crossbeams
  module Layout
    # Dashboard lane
    class DashboardItem
      attr_reader :nodes, :head_label, :head_val

      SC = StylesConfig

      def initialize
        @head_label = nil
        @head_val = nil
        @nodes = []
      end

      def header(val)
        @head_label = val
      end

      def header_value(val)
        @head_val = val
      end

      def split_header(val)
        @split_header = val
      end

      def add_label(label, opts = {})
        @nodes << DashboardLabel.new(label, opts)
      end

      def add_label_val(label, val, opts = {})
        @nodes << DashboardLabelVal.new(label, val, opts)
      end

      def add_label_val_array(ary, options = {})
        @nodes << DashboardLabelValArray.new(ary, options)
      end

      def add_number(val, options = {})
        @nodes << DashboardNumber.new(val, options)
      end

      def add_network_state(options = {})
        @nodes << DashboardNetworkState.new(options)
      end

      def add_hover_button(label, hover_text:)
        id = Random.rand
        @nodes << <<~HTML
          <div class="border-t py-1 mt-2 border-slate-300">
            <div style="display:none" data-cb-hint="dash-hb-#{id}">#{hover_text}</div>
            <button type="button" data-cb-hint-for="dash-hb-#{id}" class="#{SC.css_class(:button_primary)}">#{label}</button>
          </div>
        HTML
      end

      def render
        <<-HTML
          <div class="grid grid-rows-[auto_1fr] bg-white border rounded-md border-slate-300 p-2">
            #{head}
            #{nodes.map { |n| n.is_a?(String) ? n : n.render }.join("\n")}
          </div>
        HTML
      end

      private

      def head
        return split_header_render if @split_header

        if head_val
          %(<div class="border-b border-slate-300 pb-1 mb-1"><span class="font-medium">#{head_label}</span><span class="ml-3 text-blue-600">#{head_val}</span></div>)
        else
          %(<div class="font-medium text-center border-b border-slate-300 pb-1 mb-1">#{head_label}</div>)
        end
      end

      def split_header_render
        cnt = 0
        last = @split_header.length
        <<~HTML
          <div class="flex justify-evenly border-b border-gray-900">
            #{@split_header.map do |head|
              cnt += 1
              right = cnt < last ? ' border-r border-r-1 border-gray-900' : ''
              if head.is_a?(Array)
                %(<div class="flex-1 text-center pb-1 mb#{right}"><span class="font-medium">#{head.first}</span><span class="ml-3 text-blue-600">#{head.last}</span></div>)
              else
                %(<div class="font-medium flex-1 text-center pb-1 mb-1#{right}">#{head}</div>)
              end
            end.join("\n")}
          </div>
        HTML
      end
    end
  end
end
