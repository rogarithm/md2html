require_relative 'token'

# This class scans for a token based on a single character. If there are no
# matches, it will return a NullToken.
#
# Eg: SimpleToken.from_string("_foo") => #<Token type:'UNDERSCORE', value: '_'>
#     SimpleToken.from_string("foo")  => #<NullToken>

module Md2Html
  module Tokenizer
    class SimpleScanner
      TOKEN_TYPES = {
        '_'  => 'UNDERSCORE',
        '-'  => 'DASH',
        '*'  => 'STAR',
        "\n" => 'NEWLINE',
        '#'  => 'HASH',
        "\\" => 'ESCAPE',
        "`"  => 'BACKTICK'
      }.freeze

      def self.from_string(plain_markdown)
        char = plain_markdown[0]
        Token.new(type: TOKEN_TYPES[char], value: char)
      rescue InvalidTokenError
        Token.null
      end
    end
  end
end
