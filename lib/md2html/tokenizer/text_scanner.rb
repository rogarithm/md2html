require_relative 'token'
require_relative 'simple_scanner'

# A simple text scanner, it basically selects everything the simple scanner
# does not.

module Md2Html
  module Tokenizer
    class TextScanner < SimpleScanner
      def self.from_string(plain_markdown)
        text = plain_markdown
          .each_char
          .take_while { |char| SimpleScanner.from_string(char).present? == false }
          .join('')
        Token.new(type: 'TEXT', value: text)
      rescue InvalidTokenError
        Token.null
      end
    end
  end
end
