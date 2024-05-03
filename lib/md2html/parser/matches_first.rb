require_relative "node"

require_relative '../util/logger_factory'

module Md2Html
  module Parser
    module MatchesFirst
      # Tries to match one parser, the order is very important here as they get
      # tested first-in-first-tried.
      # If a parser matched, the function returns the matched node, otherwise, it
      # returns a null node.
      #
      def match_first(tokens, *parsers)
        @logger ||= Md2Html::Util::LoggerFactory.make_logger()

        parsers.each do |parser|
          node = parser.match(tokens)
          make_log_msg(@logger, parser, node) if node.present?
          return node if node.present?
        end
        Node.null
      end

      def make_log_msg(logger, parser, node)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} parse with #{parser}")
        logger.debug("#{path} matching result is: #{node}")
        logger.debug("#{path} when paragraph, its sentence is: #{node.sentences}") if node.type == 'PARAGRAPH'
        logger.debug("#{path} stop parsing sentences...") if node.type == 'PARAGRAPH'
      end
    end
  end
end
