require_relative 'base_parser'
require_relative 'node'

module Md2Html
  module Parser
    class DashParser < BaseParser
      def match(tokens)
        return Node.null unless tokens.peek_or(%w(DASH))
        Node.new(type: 'DASH', value: tokens.first.value, consumed: 1)
      end
    end
  end
end
