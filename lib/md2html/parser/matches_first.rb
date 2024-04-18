require 'logger'

require_relative "node"

module Md2Html
  module Parser
    module MatchesFirst
      # Tries to match one parser, the order is very important here as they get
      # tested first-in-first-tried.
      # If a parser matched, the function returns the matched node, otherwise, it
      # returns a null node.
      #
      def match_first(tokens, *parsers)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        log.debug("#{path} start parsing sentences...")
        parsers.each do |parser|
          node = parser.match(tokens)
          log.debug("#{path} parse with #{parser}") if node.present?
          log.debug("#{path} matching result is: #{node}") if node.present?
          log.debug("#{path} when paragraph, its sentence is: #{node.sentences}") if node.present? and node.type == 'PARAGRAPH'
        log.debug("#{path} stop parsing sentences...") if node.present? and node.type == 'PARAGRAPH'
          return node if node.present?
        end
        Node.null
      end
    end
  end
end
