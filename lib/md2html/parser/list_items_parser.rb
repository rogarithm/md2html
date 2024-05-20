require_relative 'base_parser'
require_relative "matches_plus"
require_relative 'node'
require_relative "list_node"

module Md2Html
  module Parser
    class ListItemsParser < BaseParser
      include MatchesPlus

      def match(tokens)
        nodes, consumed = match_plus tokens, with: list_item_parser

        return Node.null if nodes.empty?

        case
        when tokens.peek_at(consumed, 'NEWLINE', 'EOF') == true
          consumed += 2
        when tokens.peek_at(consumed, 'EOF') == true
          consumed += 1
        when tokens.peek_at(consumed, 'NEWLINE') == true
          consumed += 1
        end

        return ListNode.new(sentences: nodes, consumed: consumed)
      end
    end
  end
end

