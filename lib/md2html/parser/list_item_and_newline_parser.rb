require_relative "matches_first"

module Md2Html
  module Parser
    class ListItemAndNewlineParser < BaseParser
      include MatchesFirst

      def match(tokens)
        node = match_first tokens, list_item_parser
        return Node.null if node.null?
        return Node.null unless tokens.peek_at(node.consumed, 'NEWLINE')
        nodes, consumed = [node], node.consumed
        consumed += 1

        ListNode.new(sentences: nodes, consumed: consumed)
      end
    end

  end
end
