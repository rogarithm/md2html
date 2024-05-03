require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

require_relative '../util/logger_factory'

module Md2Html
  module Parser
    class SentencesAndNewlineParser < BaseParser
      include MatchesStar

      def initialize
        @logger = Md2Html::Util::LoggerFactory.make_logger()
      end

      def match(tokens)
        nodes, consumed = match_star tokens, with: sentence_parser
        return Node.null if nodes.empty?
        if tokens.peek_at(consumed, 'NEWLINE', 'NEWLINE')
          consumed += 2 # consume newlines
        elsif tokens.peek_at(consumed, 'NEWLINE')
          consumed += 1 # consume newline
        else
          return Node.null
        end

        pn = ParagraphNode.new(sentences: nodes, consumed: consumed)
        make_log_msg_after(@logger, pn)
        pn
      end

      def make_log_msg_after(logger, paragraph_node)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        logger.debug("#{path} CONSUMED: #{paragraph_node.consumed}")
        all_sentences = "["
        paragraph_node.sentences.each {|s| all_sentences << "<@type=\"#{s.type}\", @value=\"#{s.value}\", @consumed=#{s.consumed}>, "}
        all_sentences << "]"
        logger.debug("#{path} all_sentences: #{all_sentences}")
      end
    end
  end
end
