require_relative "base_parser"
require_relative "matches_star"
require_relative "body_node"
require_relative "node"

module Md2Html
  module Parser
    class BodyParser < BaseParser
      include MatchesStar

      def match(tokens)
        nodes, consumed, type = match_star tokens, with: block_parser
        return Node.null if nodes.empty?
        BodyNode.new(blocks: nodes, consumed: consumed)
      end
    end
  end
end
