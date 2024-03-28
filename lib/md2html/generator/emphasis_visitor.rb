module Md2Html
  module Generator
    class EmphasisVisitor
      def visit(node)
        "<em>#{node.value}</em>"
      end
    end
  end
end
