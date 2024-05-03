require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

require_relative '../util/logger_factory'

module Md2Html
  module Parser
    class SentencesAndEofParser < BaseParser
      include MatchesStar

      def initialize
        @logger = Md2Html::Util::LoggerFactory.make_logger()
      end

      def match(tokens)
        make_log_msg_before(@logger)

        nodes, consumed = match_star tokens, with: sentence_parser
        return Node.null if nodes.empty?

        if tokens.peek_at(consumed, 'NEWLINE', 'NEWLINE', 'EOF')
          consumed += 3
        elsif tokens.peek_at(consumed, 'NEWLINE', 'EOF')
          consumed += 2
        elsif tokens.peek_at(consumed, 'EOF')
          consumed += 1
        else
          return Node.null
        end

        pn = ParagraphNode.new(sentences: nodes, consumed: consumed)
        make_log_msg_after(@logger, pn)
        pn
      end

      def make_log_msg_before(logger)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} start parsing sentences...")
      end

      def make_log_msg_after(logger, paragraph_node)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} #{paragraph_node.consumed} tokens were parsed, with eof, nr chars included")
        all_sentences = "["
        paragraph_node.sentences.each {|s| all_sentences << "<@type=\"#{s.type}\", @value=\"#{s.value}\", @consumed=#{s.consumed}>, "}
        all_sentences << "]"
        logger.debug("#{path} all_sentences: #{all_sentences}")
        logger.debug("#{path} stop parsing sentences...")
      end
    end
  end
end
