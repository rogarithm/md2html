module Md2Html
  module Generator
    class DashVisitor
      def visit(node)
        "#{node.value}"
      end
    end
  end
end

