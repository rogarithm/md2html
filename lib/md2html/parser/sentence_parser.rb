require_relative "base_parser"
require_relative "matches_first"


module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def match(tokens)
        puts "Md2Html::Parser::SentenceParser TOKEN COUNT: #{tokens.count}"
        node = match_first(tokens, dash_parser, emphasis_parser, bold_parser, text_parser)
        if node.null? == false
          puts "Md2Html::Parser::SentenceParser RESULT: <@type=\"#{node.type}\", @value=\"#{node.value}\", @consumed=#{node.consumed}>" 
        else
          puts "Md2Html::Parser::SentenceParser RESULT: NullNode"
        end
        node
      end
    end
  end
end
