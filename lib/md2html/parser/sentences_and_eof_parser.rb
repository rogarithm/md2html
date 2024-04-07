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
        puts "IN SENTENCES_AND_EOF_PARSER, CONSUMED: #{pn.consumed}"
        p pn.sentences
        pn
      end
    end
  end
end
