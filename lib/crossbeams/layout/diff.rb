# frozen_string_literal: true

module Crossbeams
  module Layout
    # A diff renderer - shows the difference between two texts or two hashes.
    class Diff # rubocop:disable Metrics/ClassLength
      extend MethodBuilder

      build_methods_for :csrf
      attr_reader :key, :rules, :use_files, :sort_nested

      def initialize(page_config, key)
        @key = key
        @rules = page_config.options[:fields][key]
        raise ArgumentError, 'Diff renderer must have keys :left and :right, :left_record and :right_record or :left_file and :right_file' unless valid_keys?

        @use_files = @rules.key?(:left_file)
        @sort_nested = @rules.key?(:sort_nested) ? @rules[:sort_nested] : true
        @nodes = []
      end

      def invisible?
        false
      end

      def hidden?
        false
      end

      def render
        diff = if use_files
                 Diffy::SplitDiff.new(@rules[:left_file], @rules[:right_file], format: :html, allow_empty_diff: false, source: 'files')
               else
                 Diffy::SplitDiff.new(left_text, right_text, format: :html, allow_empty_diff: false)
               end
        left = diff.left
        right = diff.right

        <<-HTML
        <div class="crossbeams-field"#{no_padding}>
          <div class="cbl-diff-container"#{max_width}>
            <p class="cbl-diff-caption">#{rules[:left_caption] || 'Left'}</p>
            #{left}
          </div>
          <div class="cbl-diff-container"#{max_width}>
            <p class="cbl-diff-caption">#{rules[:right_caption] || 'Right'}</p>
            #{right}
          </div>
        </div>
        HTML
      end

      private

      def max_width
        return '' unless @rules[:max_pane_width]

        %( style="max-width:#{@rules[:max_pane_width]}px")
      end

      def no_padding
        return '' unless @rules[:no_padding]

        ' style="padding:0"'
      end

      def left_text
        return rules[:left] if rules[:left]

        if @rules[:unnest_records]
          unnest_rec(rules[:left_record], :left)
        else
          rec_to_s(rules[:left_record], len + 2)
        end
      end

      def right_text
        return rules[:right] if rules[:right]

        if @rules[:unnest_records]
          unnest_rec(rules[:right_record], :right)
        else
          rec_to_s(rules[:right_record], len + 2)
        end
      end

      def len
        rules[:left_record].keys.map(&:length).max
      end

      def rec_to_s(hash, len = 30)
        hash.map { |k, v| "#{k.to_s.ljust(len)}: #{format(v)}" }.join("\n")
      end

      def unnest_rec(hash, side)
        flattened = flatten_hash(hash)

        @left_len = flattened.keys.map(&:length).max if side == :left

        rec_to_s(flattened, @left_len + 2)
      end

      def symbolize_keys(hash)
        if hash.is_a?(Hash)
          Hash[
            hash.map do |k, v|
              [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize_keys(v)]
            end
          ]
        else
          hash
        end
      end

      def flatten_hash(in_hash)
        return {} if in_hash.nil?

        inter_hash = symbolize_keys(in_hash)
        hash = {}
        if sort_nested
          inter_hash.keys.sort.each { |k| hash[k] = inter_hash[k] }
        else
          hash = inter_hash
        end
        instance = {}

        hash.each do |k, v|
          add_to_instance(instance, '', k, v)
        end
        instance
      end

      def add_to_instance(instance, prefix, key, val) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if val.is_a?(Array)
          val.each_with_index do |elem, idx|
            pfx = []
            pfx << prefix unless prefix == ''
            pfx << key unless key == ''
            pfx << idx + 1
            add_to_instance(instance, pfx.join('_'), '', elem)
          end
        elsif val.is_a?(Hash)
          hash = {}
          if sort_nested
            val.keys.sort.each { |k| hash[k] = val[k] }
          else
            hash = val
          end
          hash.each do |k, v|
            pfx = []
            pfx << prefix unless prefix == ''
            pfx << key unless key == ''
            add_to_instance(instance, pfx.join('_'), k, v)
          end
        else
          pfx = []
          pfx << prefix unless prefix == ''
          pfx << key unless key == ''
          instance[pfx.join('_').to_sym] = val
        end
      end

      def format(val)
        case val
        when BigDecimal
          val.to_s('F')
        when Date
          val.strftime('%Y-%m-%d')
        when Time
          val.strftime('%Y-%m-%d %H:%M:%S')
        when String
          val.match?(/^-?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)$/) ? BigDecimal(val).to_s('F') : val
        else
          val
        end
      end

      def valid_keys?
        text_ok? || rec_ok? || file_ok?
      end

      def text_ok?
        @rules.key?(:left) && @rules.key?(:right) && %i[left_record right_record left_file right_file].none? { |key| @rules.key?(key) }
      end

      def rec_ok?
        @rules.key?(:left_record) && @rules.key?(:right_record) && %i[left right left_file right_file].none? { |key| @rules.key?(key) }
      end

      def file_ok?
        @rules.key?(:left_file) && @rules.key?(:right_file) && %i[left_record right_record left right].none? { |key| @rules.key?(key) }
      end
    end
  end
end
