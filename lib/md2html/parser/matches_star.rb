require 'logger'

module Md2Html
  module Parser
    module MatchesStar
      # This method tries to match a sentence as many times as possible. It then
      # returns all matched nodes. It's the equivalent of `*`, also known as Kleene
      # star.
      #
      def match_star(tokens, with:)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        matched_nodes = []
        consumed      = 0
        parser        = with

        log.debug("#{path} with #{parser.class},")
        log.debug("#{path} parsing tokens...: #{tokens}")
        while true
          log.debug("#{path} now parsing tokens from #{consumed}th element...")
          node = parser.match(tokens.offset(consumed))
          log.debug("#{path} matched node is: #{node.class}")

          break if node.null?
          matched_nodes += [node]
          consumed      += node.consumed
        end

        [matched_nodes, consumed]
      end
    end
  end
end
