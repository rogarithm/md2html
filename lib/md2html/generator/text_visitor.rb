module Md2Html
  module Generator
    class TextVisitor
      def visit(node)
        node.value
      end
    end
  end
end
