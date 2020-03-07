# frozen_string_literal: true

module Crossbeams
  module Layout
    # A diff renderer - shows the difference between two texts or two hashes.
    class Diff
      include PageNode
      attr_reader :key, :rules, :use_files

      def initialize(page_config, key)
        @key = key
        @rules = page_config.options[:fields][key]
        raise ArgumentError, 'Diff renderer must have keys :left and :right, :left_record and :right_record or :left_file and :right_file' unless valid_keys?

        @use_files = @rules.key?(:left_file)
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
        left  =  diff.left
        right =  diff.right

        <<-HTML
        <div class="crossbeams-field"#{no_padding}>
          <div class="cbl-diff-container">
            <p class="cbl-diff-caption">#{rules[:left_caption] || 'Left'}</p>
            #{left}
          </div>
          <div class="cbl-diff-container">
            <p class="cbl-diff-caption">#{rules[:right_caption] || 'Right'}</p>
            #{right}
          </div>
        </div>
        HTML
      end

      private

      def no_padding
        return '' unless @rules[:no_padding]

        ' style="padding:0"'
      end

      def left_text
        return rules[:left] if rules[:left]

        rec_to_s(rules[:left_record], len + 2)
      end

      def right_text
        return rules[:right] if rules[:right]

        rec_to_s(rules[:right_record], len + 2)
      end

      def len
        rules[:left_record].keys.map(&:length).max
      end

      def rec_to_s(hash, len = 30)
        hash.map { |k, v| "#{k.to_s.ljust(len)}: #{v}" }.join("\n")
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
