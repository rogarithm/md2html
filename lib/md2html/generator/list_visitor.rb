require_relative "list_item_visitor"

module Md2Html
  module Generator
    class ListVisitor
      def visit(list_node)
        "<ul>
#{list_items_for(list_node)}
</ul>"
      end

      private

      def list_items_for(list_node)
        list_node.sentences.map do |list_item|
          "  #{list_item_visitor.visit(list_item)}"
        end.join("\n")
      end

      def list_item_visitor
        @list_item_visitor ||= ListItemVisitor.new
      end
    end

  end
end
