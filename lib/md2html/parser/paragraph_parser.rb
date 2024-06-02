require_relative "base_parser"
require_relative "matches_plus"
require_relative "sentence_parser"
require_relative "paragraph_node"

module Md2Html
  module Parser
    class ParagraphParser < BaseParser
      include MatchesPlus

      def match(tokens)
        sentences, consumed = match_plus tokens, with: sentence_parser
        if sentences.size == 0
          return Node.null
        end

        ParagraphNode.new(sentences: sentences, consumed: consumed)
      end
    end
  end
end
