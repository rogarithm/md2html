require_relative 'base_parser'
require_relative "matches_plus"
require_relative 'node'
require_relative "list_node"

module Md2Html
  module Parser
    class ListItemsParser < BaseParser
      include MatchesPlus

      def match(tokens)
        nodes, consumed = match_plus(tokens, with: list_item_parser) do |all_tokens, consumed_now|
          all_tokens.peek_from(consumed_now, 'NEWLINE')
        end

        return Node.null if nodes.empty?

        case
        when tokens.peek_from(consumed, 'NEWLINE', 'EOF') == true
          consumed += 2
        when tokens.peek_from(consumed, 'EOF') == true
          consumed += 1
        when tokens.peek_from(consumed, 'NEWLINE') == true
          consumed += 1
        end

        return ListNode.new(sentences: nodes, consumed: consumed)
      end
    end
  end
end

