module Md2Html
  module Generator
    class HeadingVisitor
      def visit(heading_node)
        heading_value = heading_node.sentences.first.words.first.value
        if heading_node.type == "HEADING"
          "<h1>#{heading_value}</h1>"
        elsif heading_node.type == "HEADING_LEVEL2"
          "<h2>#{heading_value}</h2>"
        end
      end
    end
  end
end
