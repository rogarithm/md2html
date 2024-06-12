require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "sentence_node"

module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesStar

      def match(tokens)
        nodes, consumed = match_star tokens, with: sentence_element_parser
        return Node.null if nodes.empty?

        case
        when tokens.peek_from(consumed, 'NEWLINE', 'NEWLINE', 'EOF') == true
          consumed += 3
        when tokens.peek_from(consumed, 'NEWLINE', 'NEWLINE') == true
          consumed += 2
        when tokens.peek_from(consumed, 'NEWLINE', 'EOF') == true
          consumed += 2
        when tokens.peek_from(consumed, 'NEWLINE') == true
          nodes << Node.new(type: 'NEWLINE', value: '\n', consumed: 1)
          consumed += 1
        when tokens.peek_from(consumed, 'EOF') == true
          consumed += 1
        end

        SentenceNode.new(words: nodes, consumed: consumed)
      end
    end
  end
end

