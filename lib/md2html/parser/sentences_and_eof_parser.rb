require 'logger'

require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

module Md2Html
  module Parser
    class SentencesAndEofParser < BaseParser
      include MatchesStar

      def match(tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        nodes, consumed = match_star tokens, with: sentence_parser
        log.debug("#{path} ---------HERE--------- NODES: #{nodes}, CONSUMED: #{consumed}")
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
        log.debug("#{path} CONSUMED: #{pn.consumed}")
        all_sentences = "["
        pn.sentences.each {|s| all_sentences << "<@type=\"#{s.type}\", @value=\"#{s.value}\", @consumed=#{s.consumed}>, "}
        all_sentences << "]"
        log.debug("#{path} all_sentences: #{all_sentences}")
        pn
      end
    end
  end
end
