require_relative "base_parser"
require_relative "matches_first"

module Md2Html
  module Parser
    class BlockParser < BaseParser
      include MatchesFirst

      def match(tokens)
        match_first tokens, list_parser, paragraph_parser
      end
    end
  end
end
