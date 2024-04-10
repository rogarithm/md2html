require 'logger'

require_relative "base_parser"
require_relative "matches_star"
require_relative "node"
require_relative "paragraph_node"

module Md2Html
  module Parser
    class SentencesAndNewlineParser < BaseParser
      include MatchesStar

      def match(tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        nodes, consumed = match_star tokens, with: sentence_parser
        return Node.null if nodes.empty?
        if tokens.peek_at(consumed, 'NEWLINE')
          consumed += 1 # consume newline
        elsif tokens.peek_at(consumed, 'NEWLINE', 'NEWLINE')
          consumed += 2 # consume newlines
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
