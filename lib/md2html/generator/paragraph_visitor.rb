require_relative "sentence_visitor"

module Md2Html
  module Generator
    class ParagraphVisitor
      def visit(paragraph_node)
        "<p>
  #{sentences_for(paragraph_node)}
</p>"
      end

      private

      def sentences_for(paragraph_node)
        paragraph_node.sentences.map do |sentence|
          "#{sentence_visitor.visit(sentence)}"
        end.join
      end

      def sentence_visitor
        @sentence_visitor ||= SentenceVisitor.new
      end
    end
  end
end
