module Md2Html
  module Generator
    class HeadingVisitor
      def visit(heading_node)
        "<h1>#{heading_node.value}</h1>"
      end
    end
  end
end
