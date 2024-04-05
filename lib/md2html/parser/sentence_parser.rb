require_relative "base_parser"
require_relative "matches_first"


module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def match(tokens)
        puts "IN SENTENCE PARSER"
        puts "TOKEN COUNT IS: #{tokens.count}"
        node = match_first(tokens, dash_parser, emphasis_parser, bold_parser, text_parser)
        puts "SENTENCE PARSER'S RESULT IS: #{node}"
        node
      end
    end
  end
end
