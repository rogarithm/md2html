require_relative 'tokenizer/simple_scanner'
require_relative 'tokenizer/text_scanner'
require_relative 'tokenizer/token_list'

# A tokenizer, the purpose of this class is to transform a markdown string
# into a list of "tokens". In this case, each token has a type and a value.
#
# Example:
#   "_Hi!_" => [{type: UNDERSCORE, value: '_'}, {type: TEXT, value: 'Hi!'},
#               {type: UNDERSCORE, value: '_'}]

module Md2Html
  module Tokenizer
    TOKEN_SCANNERS = [
      Tokenizer::SimpleScanner, # Recognizes simple one-char tokens like `_` and `*`
      Tokenizer::TextScanner    # Recognizes everything but a simple token
    ].freeze

    def self.tokenize(plain_markdown)
      tokens_array = tokens_as_array(plain_markdown)
      Tokenizer::TokenList.new(tokens_array)
    end

    private

    def self.tokens_as_array(plain_markdown)
      if plain_markdown.nil? || plain_markdown == ''
        return [Tokenizer::Token.end_of_file]
      end

      token = scan_one_token(plain_markdown)
      [token] + tokens_as_array(plain_markdown[token.length..-1])
    end

    def self.scan_one_token(plain_markdown)
      TOKEN_SCANNERS.each do |scanner|
        token = scanner.from_string(plain_markdown)
        return token if token.present?
      end
      raise "The scanners could not match the given input: #{plain_markdown}"
    end
  end
end
