module Md2Html
  module Generator
    class HeadingVisitor
      def visit(heading_node)
        if heading_node.type == "HEADING"
          "<h1>#{heading_node.value}</h1>"
        elsif heading_node.type == "HEADING_LEVEL2"
          "<h2>#{heading_node.value}</h2>"
        end
      end
    end
  end
end
