require 'logger'

require_relative "base_parser"
require_relative "matches_first"


module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def match(tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new('.md2html.log')
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        log.debug("#{path} parsing #{tokens.count} tokens...")
        node = match_first(tokens, dash_parser, emphasis_parser, bold_parser, text_parser)
        if node.null? == false
          log.debug("#{path} parse success. detail: <@type=\"#{node.type}\", @value=\"#{node.value}\", @consumed=#{node.consumed}>")
        else
          log.debug("#{path} parse failed. result is NullNode")
        end
        node
      end
    end
  end
end
