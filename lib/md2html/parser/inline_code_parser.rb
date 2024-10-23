require_relative 'base_parser'

module Md2Html
  module Parser
    class InlineCodeParser < BaseParser
      def match(tokens)
        return Node.null unless tokens.peek('CODE')
        Node.new(type: 'CODE', value: tokens.first.value, consumed: 1)
      end
    end
  end
end
