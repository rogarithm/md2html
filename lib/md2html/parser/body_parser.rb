require_relative "base_parser"
require_relative "matches_star"
require_relative "body_node"
require_relative "node"

module Md2Html
  module Parser
    class BodyParser < BaseParser
      include MatchesStar

      def match(tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        log.debug("#{path} BODY_PARSER")
        nodes, consumed, type = match_star tokens, with: block_parser
        return Node.null if nodes.empty?
        log.debug("#{path} NODES: #{nodes}")
        log.debug("#{path} CONSUMED: #{consumed}")
        BodyNode.new(blocks: nodes, consumed: consumed)
      end
    end
  end
end
