require_relative 'parser/parser_factory'

# Transforms a list of tokens into an Abstract Syntax Tree.

module Md2Html
  module Parser
    def self.parse(tokens)
      body = body_parser.match(tokens)
      puts "Md2Html::Parser tokens.count: #{tokens.count}"
      all_tokens_info = ""
      tokens.each {|t| all_tokens_info << "#{t.value}(#{t.type})"}
      puts "Md2Html::Parser all_tokens_info: #{all_tokens_info}"
      puts "Md2Html::Parser body.consumed: #{body.consumed}"
      raise "Syntax error: tokens.count is not equal to body.consumed" unless tokens.count == body.consumed
      body
    end

    private

    def self.body_parser
      @body_parser ||= ParserFactory.build(:body_parser)
    end
  end
end
