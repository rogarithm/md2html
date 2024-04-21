require_relative 'base_parser'
require_relative 'node'

module Md2Html
  module Parser
    class HeaderParser < BaseParser
      def match(tokens)
        if tokens.peek_or(%w(HASH HASH HASH TEXT))
          return Node.new(type: 'HEADER_LEVEL3', value: tokens.nth(4).value.strip(), consumed: 4)
        end

        if tokens.peek_or(%w(HASH HASH HASH HASH TEXT))
          return Node.new(type: 'HEADER_LEVEL4', value: tokens.nth(5).value.strip(), consumed: 5)
        end

        return Node.null
      end
    end
  end
end
