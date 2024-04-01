module Md2Html
  module Generator
    class ListItemVisitor
      def visit(list_item_node)
        "<li>#{list_item_node.value.strip}</li>"
      end
    end


  end
end
