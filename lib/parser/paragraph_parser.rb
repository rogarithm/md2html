require_relative "base_parser"
require_relative "matches_first"

class ParagraphParser < BaseParser
  include MatchesFirst

  def match(tokens)
    match_first tokens, sentences_and_newline_parser, sentences_and_eof_parser
  end
end
