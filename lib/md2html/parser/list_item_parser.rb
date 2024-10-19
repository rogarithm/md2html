require_relative "base_parser"
require_relative "node"

module Md2Html
  module Parser
    class ListItemParser < BaseParser
      def match(tokens)
        return Node.null unless tokens.peek_or(%w(DASH TEXT NEWLINE))
        SentenceNode.new({
          type: 'LIST_ITEM',
          words: [Node.new(type: 'TEXT', value: tokens.second.value, consumed: 1)],
          consumed: 3
        })
      end
    end
  end
end
