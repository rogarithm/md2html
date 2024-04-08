require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

module Md2Html
  module Parser
    class SentencesAndEofParser < BaseParser
      include MatchesStar

      def match(tokens)
        nodes, consumed = match_star tokens, with: sentence_parser
        return Node.null if nodes.empty?
        if tokens.peek_at(consumed, 'NEWLINE', 'EOF')
          consumed += 2
        elsif tokens.peek_at(consumed, 'NEWLINE', 'NEWLINE', 'EOF')
          consumed += 3
        else
          return Node.null
        end

        pn = ParagraphNode.new(sentences: nodes, consumed: consumed)
        puts "Md2Html::Parser::SentencesAndEofParser CONSUMED: #{pn.consumed}"
        all_sentences = "["
        pn.sentences.each {|s| all_sentences << "<@type=\"#{s.type}\", @value=\"#{s.value}\", @consumed=#{s.consumed}>, "}
        all_sentences << "]"
        puts "Md2Html::Parser::SentencesAndEofParser all_sentences: #{all_sentences}"
        pn
      end
    end
  end
end
