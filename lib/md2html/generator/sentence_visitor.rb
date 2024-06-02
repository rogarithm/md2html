require_relative 'bold_visitor'
require_relative 'emphasis_visitor'
require_relative 'text_visitor'
require_relative 'dash_visitor'
require_relative 'newline_visitor'

module Md2Html
  module Generator
    class SentenceVisitor
      SENTENCE_VISITORS = {
        "BOLD"     => BoldVisitor,
        "EMPHASIS" => EmphasisVisitor,
        "TEXT"     => TextVisitor,
        "DASH"     => DashVisitor,
        "NEWLINE"  => NewlineVisitor
      }.freeze

      def visit(sentence_node)
        sentence_node.words.map do |word|
          "#{visitor_for(word).visit(word)}"
        end.join
      end

      private

      def visitor_for(word)
        SENTENCE_VISITORS.fetch(word.type) { raise "Invalid sentence node type! It might be there's no sufficient visitor for a character or markdown element to generate html. If it's the case, consider add a new visitor for that." }.new
      end
    end
  end
end
