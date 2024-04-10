require_relative "base_parser"
require_relative "matches_first"

module Md2Html
  module Parser
    class ParagraphParser < BaseParser
      include MatchesFirst

      def match(tokens)
        match_first tokens, sentences_and_eof_parser, sentences_and_newline_parser
      end
    end
  end
end
