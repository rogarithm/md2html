require_relative "base_parser"
require_relative "matches_first"

module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def match(tokens)
        match_first tokens, dash_parser, emphasis_parser, bold_parser, text_parser
        puts "IN SENTENCE PARSER, TOKEN COUNT IS: #{tokens.count}"
      end
    end
  end
end
