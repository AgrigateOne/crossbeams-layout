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
        @stretch = true
        @nodes = []
      end

      def no_stretch!
        @stretch = false
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

      def add_percentage(val, options = {})
        @nodes << DashboardPercentage.new(val, options)
      end

      def add_network_state(options = {})
        @nodes << DashboardNetworkState.new(options)
      end

      def add_popup_button(label, popup_text: nil, popup_table: {})
        id = Random.rand
        html = popup_text || make_table(popup_table)
        @nodes << <<~HTML
          <div class="border-t py-1 mt-2 border-slate-300 text-center">
            <div style="display:none" data-cb-hint="dash-hb-#{id}">#{html}</div>
            <button type="button" data-cb-hint-for="dash-hb-#{id}" class="#{SC.css_class(:button_primary)}">#{label}</button>
          </div>
        HTML
      end

      def add_table(rows, cols, caption = nil, opts = {})
        caption_html = %(<div class="font-medium">#{caption}</div>) unless caption.nil?
        html = make_table({ rows: rows, cols: cols }.merge(opts))
        # <div class="border-t py-1 mt-2 border-slate-300">
        @nodes << <<~HTML
          <div class="py-1 mt-2">
            #{caption_html}
            #{html}
          </div>
        HTML
      end

      def render
        <<-HTML
          <div class="#{stretch_class}grid grid-rows-[auto_1fr] bg-white border rounded-md border-slate-300 p-2 max-w-md">
            #{head}
            #{nodes.map { |n| n.is_a?(String) ? n : n.render }.join("\n")}
          </div>
        HTML
      end

      private

      def stretch_class
        @stretch ? '' : 'self-baseline '
      end

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

      def make_table(opts)
        tbl = Table.new({}, opts.delete(:rows), opts.delete(:cols), opts)
        tbl.render
      end
    end
  end
end
