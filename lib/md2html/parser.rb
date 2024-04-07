require_relative 'parser/parser_factory'

# Transforms a list of tokens into an Abstract Syntax Tree.

module Md2Html
  module Parser
    def self.parse(tokens)
      body = body_parser.match(tokens)
      puts "tokens.count: #{tokens.count}"
      p tokens
      puts "body.consumed: #{body.consumed}"
      raise "Syntax error: tokens.count is not equal to body.consumed" unless tokens.count == body.consumed
      body
    end

    private

    def self.body_parser
      @body_parser ||= ParserFactory.build(:body_parser)
    end
  end
end
