require_relative 'base_parser'
require_relative "matches_first"
require_relative 'node'

module Md2Html
  module Parser
    class HeadingParser < BaseParser
      include MatchesFirst

      def match(tokens)
        return Node.null unless tokens.peek_or(%w(HASH TEXT NEWLINE))
        Node.new(type: 'HEADING', value: tokens.second.value, consumed: 4)
      end
    end
  end
end


