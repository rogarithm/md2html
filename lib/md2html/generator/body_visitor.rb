require_relative "paragraph_visitor"
require_relative "list_visitor"
require_relative "heading_visitor"

module Md2Html
  module Generator
    class BodyVisitor
      def visit(body_node)
        body_node.blocks.map do |block|
          if block.type == "PARAGRAPH"
            paragraph_visitor.visit(block)
          elsif block.type == "LIST"
            list_visitor.visit(block)
          elsif block.type.start_with? "HEADING"
            heading_visitor.visit(block)
          end
        end.join("\n") << "\n"
      end

      private

      def paragraph_visitor
        @paragraph_visitor ||= ParagraphVisitor.new
      end

      def list_visitor
        @list_visitor ||= ListVisitor.new
      end

      def heading_visitor
        @heading_visitor ||= HeadingVisitor.new
      end
    end
  end
end
