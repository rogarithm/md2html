require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

module Md2Html
  module Parser
    class SentencesAndNewlineParser < BaseParser
      include MatchesStar

      def match(tokens)
        nodes, consumed = match_star tokens, with: sentence_parser
        return Node.null if nodes.empty?
        return Node.null unless tokens.peek_at(consumed, 'NEWLINE', 'NEWLINE')
        consumed += 2 # consume newlines

        pn = ParagraphNode.new(sentences: nodes, consumed: consumed)
        puts "IN SENTENCES_AND_NEWLINE_PARSER, CONSUMED: #{pn.consumed}"
        p pn.sentences
        pn
      end
    end
  end
end
