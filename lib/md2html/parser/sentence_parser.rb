require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "sentence_node"

module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesStar

      def match(tokens)
        nodes, consumed = match_star tokens, with: sentence_element_parser
        return Node.null if nodes.empty?

        case
        when tokens.peek_from(consumed, 'NEWLINE', 'NEWLINE') == true
          newline_count = 2
          while tokens.peek_from(consumed + newline_count, 'NEWLINE') == true
            newline_count += 1
          end

          # 단락의 끝일 경우
          if tokens.peek_from(consumed + newline_count, 'EOF') == false
            consumed += newline_count
            return SentenceNode.ends_early({words: nodes, consumed: consumed})
          end
          # 문서 전체의 끝일 경우
          consumed += newline_count + 1  # +1 for EOF
        when tokens.peek_from(consumed, 'NEWLINE', 'EOF') == true
          consumed += 2
        when tokens.peek_from(consumed, 'NEWLINE') == true
          nodes << Node.new(type: 'NEWLINE', value: '\n', consumed: 1)
          consumed += 1
        when tokens.peek_from(consumed, 'EOF') == true
          consumed += 1
        end

        SentenceNode.new(words: nodes, consumed: consumed)
      end
    end
  end
end

