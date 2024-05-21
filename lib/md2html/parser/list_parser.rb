require_relative "base_parser"
require_relative "matches_first"

module Md2Html
  module Parser
    class ListParser < BaseParser
      include MatchesFirst

      def match(tokens)
        match_first tokens, list_items_parser
      end
    end
  end
end
