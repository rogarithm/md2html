require_relative 'base_parser'

module Md2Html
  module Parser
    class TextParser < BaseParser
      def match(tokens)
        return Node.null unless tokens.peek('TEXT')
        Node.new(type: 'TEXT', value: tokens.first.value, consumed: 1)
      end
    end
  end
end
