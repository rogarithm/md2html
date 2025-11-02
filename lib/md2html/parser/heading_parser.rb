require_relative 'base_parser'
require_relative "matches_first"
require_relative 'heading_node'

module Md2Html
  module Parser
    class HeadingParser < BaseParser
      def match(tokens)
        return Node.null if tokens.peek_from(0, 'HASH') == false

        left = Node.null
        hash_count = 0
        if tokens.peek_from(0, 'HASH', 'HASH')
          left = tokens.offset(2)
          hash_count = 2
        elsif tokens.peek_from(0, 'HASH')
          left = tokens.offset(1)
          hash_count = 1
        end

        node_type = 'HEADING'
        if hash_count == 2
          node_type += '_LEVEL2'
        end

        single_sentence = [
          SentenceNode.new({
            words: [Node.new(type: 'TEXT', value: left.first.value, consumed: 1)],
            consumed: 1
          })
        ]

        # TEXT 토큰 이후 NEWLINE 패턴 확인 및 모든 연속 개행 소비
        if left.peek_or(%w(TEXT NEWLINE NEWLINE)) == true
          # 2개 이상의 연속 NEWLINE을 모두 소비 (마크다운 표준)
          newline_count = 2
          while left.peek_from(1 + newline_count, 'NEWLINE') == true
            newline_count += 1
          end

          # EOF 확인
          if left.peek_from(1 + newline_count, 'EOF') == true
            consumed = 1 + newline_count + 1 + hash_count  # TEXT + NEWLINEs + EOF + HASHes
          else
            consumed = 1 + newline_count + hash_count  # TEXT + NEWLINEs + HASHes
          end

          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: consumed)
        elsif left.peek_or(%w(TEXT NEWLINE EOF)) == true
          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: 3 + hash_count)
        elsif left.peek_or(%w(TEXT NEWLINE)) == true
          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: 2 + hash_count)
        end
      end
    end
  end
end
