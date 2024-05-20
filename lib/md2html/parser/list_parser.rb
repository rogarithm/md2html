require_relative "base_parser"
require_relative "matches_first"

module Md2Html
  module Parser
    class ListParser < BaseParser
      include MatchesFirst

      def match(tokens)
        match_first tokens, list_items_and_newline_parser, list_items_and_eof_parser
      end
    end
  end
end
