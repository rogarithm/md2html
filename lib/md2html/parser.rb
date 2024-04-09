require 'logger'

require_relative 'parser/parser_factory'

# Transforms a list of tokens into an Abstract Syntax Tree.

module Md2Html
  module Parser
    def self.parse(tokens)
      path = "#{File.dirname(__FILE__).split("/")[-1]}/#{File.basename(__FILE__)}"
      log = Logger.new(STDOUT)
      log.level = Logger::DEBUG
      log.datetime_format = "%H:%M:%S"

      log.debug("#{path} tokens.count: #{tokens.count}")
      all_tokens_info = ""
      tokens.each {|t| all_tokens_info << "#{t.value}(#{t.type})"}
      log.debug("#{path} all_tokens_info: #{all_tokens_info}")

      body = body_parser.match(tokens)

      log.debug("#{path} body.consumed: #{body.consumed}")
      raise "Syntax error: tokens.count is not equal to body.consumed" unless tokens.count == body.consumed
      body
    end

    private

    def self.body_parser
      @body_parser ||= ParserFactory.build(:body_parser)
    end
  end
end
