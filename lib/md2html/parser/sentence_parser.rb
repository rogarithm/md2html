require 'logger'

require_relative "base_parser"
require_relative "matches_first"


module Md2Html
  module Parser
    class SentenceParser < BaseParser
      include MatchesFirst

      def match(tokens)
        path = "#{File.dirname(__FILE__).split("/")[-2..-1].join("/")}/#{File.basename(__FILE__)}"
        log = Logger.new(STDOUT)
        log.level = Logger::DEBUG
        log.datetime_format = "%H:%M:%S"

        log.debug("#{path} TOKEN COUNT: #{tokens.count}")
        node = match_first(tokens, dash_parser, emphasis_parser, bold_parser, text_parser)
        if node.null? == false
          log.debug("#{path} RESULT: <@type=\"#{node.type}\", @value=\"#{node.value}\", @consumed=#{node.consumed}>")
        else
          log.debug("#{path} RESULT: NullNode")
        end
        node
      end
    end
  end
end
