require_relative "matches_first"
require_relative "node"
require_relative "list_node"

module Md2Html
  module Parser
    class ListItemAndEofParser < BaseParser
      include MatchesFirst

      def match(tokens)
        node = match_first tokens, list_item_parser
        return Node.null if node.null?
        return Node.null unless tokens.peek_at(node.consumed, 'EOF')
        nodes, consumed = [node], node.consumed
        consumed += 1

        ListNode.new(sentences: nodes, consumed: consumed)
      end
    end

  end
end
