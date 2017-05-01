module Crossbeams
  module Layout
    # PageNode - base class for other nodes to inherit from.
    module PageNode
      def add_csrf_tag(tag)
        @nodes.each { |node| node.add_csrf_tag(tag) }
      end
    end
  end
end
