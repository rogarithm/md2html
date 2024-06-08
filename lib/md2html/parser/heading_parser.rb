require_relative 'base_parser'
require_relative "matches_first"
require_relative 'node'

module Md2Html
  module Parser
    class HeadingParser < BaseParser
      include MatchesFirst

      def match(tokens)
        return Node.null unless tokens.peek_or(%w(HASH TEXT NEWLINE))
        if tokens.peek_or(%w(HASH TEXT NEWLINE NEWLINE)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 4)
        elsif tokens.peek_or(%w(HASH TEXT NEWLINE EOF)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 4)
        elsif tokens.peek_or(%w(HASH TEXT NEWLINE)) == true
          Node.new(type: 'HEADING', value: tokens.second.value, consumed: 3)
        end
      end
    end
  end
end


