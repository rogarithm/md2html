require_relative 'base_parser'
require_relative 'node'

module Md2Html
  module Parser
    class InlineParser < BaseParser
      def match(tokens)
        case
        when tokens.peek_or(%w(UNDERSCORE UNDERSCORE TEXT UNDERSCORE UNDERSCORE), %w(STAR STAR TEXT STAR STAR)) == true
          return Node.new(type: 'BOLD', value: tokens.third.value, consumed: 5)
        when tokens.peek_or(%w(UNDERSCORE TEXT UNDERSCORE), %w(STAR TEXT STAR)) == true
          return Node.new(type: 'EMPHASIS', value: tokens.second.value, consumed: 3)
        when tokens.peek_or(%w(DASH)) == true
          return Node.new(type: 'DASH', value: tokens.first.value, consumed: 1)
        else
          return Node.null
        end
      end
    end
  end
end

