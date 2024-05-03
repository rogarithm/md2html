require_relative "base_parser"
require_relative "matches_star"
require_relative "body_node"
require_relative "node"

require_relative '../util/logger_factory'

module Md2Html
  module Parser
    class BodyParser < BaseParser
      include MatchesStar

      def initialize
        @logger = Md2Html::Util::LoggerFactory.make_logger()
      end

      def match(tokens)
        nodes, consumed, type = match_star tokens, with: block_parser

        make_log_msg(@logger, nodes, consumed)

        return Node.null if nodes.empty?
        BodyNode.new(blocks: nodes, consumed: consumed)
      end

      def make_log_msg(logger, nodes, consumed)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} BODY_PARSER")
        if nodes.empty? == false
          logger.debug("#{path} NODES: #{nodes}")
          logger.debug("#{path} CONSUMED: #{consumed}")
        end
        if nodes.empty?
          logger.debug("#{path} BODY_PARSER FAILED TO PARSE")
        end
      end
    end
  end
end
