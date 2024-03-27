require_relative "base_parser"

module Md2Html
  module Parser
    class ListItemParser < BaseParser
      def match(tokens)
        return Node.null unless tokens.peek_or(%w(DASH TEXT NEWLINE))
        Node.new(type: 'LIST_ITEM', value: tokens.second.value, consumed: 3)
      end
    end
  end
end
