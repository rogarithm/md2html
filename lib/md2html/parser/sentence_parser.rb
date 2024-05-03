require_relative "base_parser"
require_relative "matches_first"

require_relative '../util/logger_factory'

module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def initialize
        @logger = Md2Html::Util::LoggerFactory.make_logger()
      end

      def match(tokens)
        make_log_msg_before(@logger, tokens)
        node = match_first(tokens, dash_parser, emphasis_parser, bold_parser, text_parser)
        make_log_msg_after(@logger, node)
        node
      end

      def make_log_msg_before(logger, tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} parsing #{tokens.count} tokens...")
      end

      def make_log_msg_after(logger, node)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        if node.null? == false
          logger.debug("#{path} parse success. detail: <@type=\"#{node.type}\", @value=\"#{node.value}\", @consumed=#{node.consumed}>")
        else
          logger.debug("#{path} parse failed. result is NullNode")
        end
      end
    end
  end
end
