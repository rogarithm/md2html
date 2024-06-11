require_relative 'base_parser'
require_relative "matches_first"
require_relative 'node'

module Md2Html
  module Parser
    class HeadingParser < BaseParser
      def match(tokens)
        return Node.null if tokens.peek_from(0, 'HASH') == false

        left = Node.null
        hash_count = 0
        if tokens.peek_from(0, 'HASH')
          left = tokens.offset(1)
          hash_count = 1
        end

        if left.peek_or(%w(TEXT NEWLINE NEWLINE)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 4)
        elsif left.peek_or(%w(TEXT NEWLINE EOF)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 4)
        elsif left.peek_or(%w(TEXT NEWLINE)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 3)
        end
      end
    end
  end
end


