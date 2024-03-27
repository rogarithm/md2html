require_relative "base_parser"
require_relative "parsers/concerns/matches_first"

class BlockParser < BaseParser
  include MatchesFirst

  def match(tokens)
    match_first tokens, list_parser, paragraph_parser
  end
end
