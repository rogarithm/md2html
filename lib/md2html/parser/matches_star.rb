require_relative '../util/logger_factory'

module Md2Html
  module Parser
    module MatchesStar
      # This method tries to match a sentence as many times as possible. It then
      # returns all matched nodes. It's the equivalent of `*`, also known as Kleene
      # star.
      #
      def match_star(tokens, with:)
        @logger = Md2Html::Util::LoggerFactory.make_logger()

        matched_nodes = []
        consumed      = 0
        parser        = with

        make_log_msg_before(@logger, parser, tokens)
        while true
          node = parser.match(tokens.offset(consumed))
          make_log_msg_after(@logger, node, consumed)

          break if node.null?
          matched_nodes += [node]
          consumed      += node.consumed
        end

        [matched_nodes, consumed]
      end

      def make_log_msg_before(logger, parser, tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} with #{parser.class},")
        logger.debug("#{path} parsing tokens...: #{tokens}")
      end

      def make_log_msg_after(logger, node, consumed)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} now parsing tokens from #{consumed}th element...")
        logger.debug("#{path} matched node is: #{node.class}")
      end
    end
  end
end
