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
        if left.peek_or(%w(TEXT NEWLINE NEWLINE)) == true
          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: 3 + hash_count)
        elsif left.peek_or(%w(TEXT NEWLINE EOF)) == true
          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: 3 + hash_count)
        elsif left.peek_or(%w(TEXT NEWLINE)) == true
          HeadingNode.new(type: node_type, sentences: single_sentence, consumed: 2 + hash_count)
        end
      end
    end
  end
end
