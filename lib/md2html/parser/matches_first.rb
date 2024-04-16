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

        parsers.each do |parser|
          node = parser.match(tokens)
          log.debug("#{path} parser: #{parser}") if node.present?
          log.debug("#{path} result: #{node}") if node.present?
          return node if node.present?
        end
        Node.null
      end
    end
  end
end
