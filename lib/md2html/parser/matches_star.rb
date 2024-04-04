module Md2Html
  module Parser
    module MatchesStar
      # This method tries to match a sentence as many times as possible. It then
      # returns all matched nodes. It's the equivalent of `*`, also known as Kleene
      # star.
      #
      def match_star(tokens, with:)
        matched_nodes = []
        consumed      = 0
        parser        = with

        puts "IN MATCHES_STAR"
        puts "PARSER IS:"
        p parser
        while true
          node = parser.match(tokens.offset(consumed))
          puts "NODE IS:"
          p node
          break if node.null?
          matched_nodes += [node]
          consumed      += node.consumed
        end

        [matched_nodes, consumed]
      end
    end
  end
end
