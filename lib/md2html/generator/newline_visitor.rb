module Md2Html
  module Generator
    class NewlineVisitor
      def visit(node)
        "<br>"
      end
    end
  end
end

