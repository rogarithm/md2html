require_relative "base_parser"
require_relative "node"

module Md2Html
  module Parser
    class ListItemParser < BaseParser
      def match(tokens)
        merge2txt = tokens.peek_until('LIST_MARK', ['NEWLINE', 'EOF'])
        return Node.null if merge2txt.nil? or merge2txt.has_no_token

        SentenceNode.new({
          type: 'LIST_ITEM',
          words: [Node.new(type: 'TEXT', value: merge2txt.values, consumed: merge2txt.size)],
          consumed: 2 + merge2txt.size
        })
      end
    end
  end
end
