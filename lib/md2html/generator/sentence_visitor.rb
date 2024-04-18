require_relative 'bold_visitor'
require_relative 'emphasis_visitor'
require_relative 'text_visitor'
require_relative 'dash_visitor'

module Md2Html
  module Generator
    class SentenceVisitor
      SENTENCE_VISITORS = {
        "BOLD"     => BoldVisitor,
        "EMPHASIS" => EmphasisVisitor,
        "TEXT"     => TextVisitor,
        "DASH"     => DashVisitor
      }.freeze

      def visit(node)
        visitor_for(node).visit(node)
      end

      private

      def visitor_for(node)
        SENTENCE_VISITORS.fetch(node.type) { raise "Invalid sentence node type! It might be there's no sufficient visitor for a character or markdown element to generate html. If it's the case, consider add a new visitor for that." }.new
      end
    end
  end
end
