module Md2Html
  module Generator
    class BoldVisitor
      def visit(node)
        "<strong>#{node.value}</strong>"
      end
    end
  end
end
