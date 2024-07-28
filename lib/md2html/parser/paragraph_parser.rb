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

        ends_early = sentences.find_index {|s| s.type == 'SENTENCE_ENDS_EARLY'}
        if ends_early != nil
          return ParagraphNode.new(
            sentences: sentences[0..ends_early],
            consumed: sentences[0..ends_early].inject(0) {|new_consumed, sentence| new_consumed + sentence.consumed}
          )
        end

        ParagraphNode.new(sentences: sentences, consumed: consumed)
      end
    end
  end
end
