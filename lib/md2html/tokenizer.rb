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
      inline_code_merged_tokens = merge_inline_code_chars(tokens_array)
      escape_merged_tokens = merge_chars2escape(inline_code_merged_tokens)
      Tokenizer::TokenList.new(escape_merged_tokens)
    end

    def self.merge_inline_code_chars(tokens_array)
      # backtick 문자의 위치를 찾는다
      backtick_idx_list = tokens_array.map.with_index do |token, idx|
        idx if token.type == 'BACKTICK'
      end.compact

      if backtick_idx_list.size == 0
        return tokens_array
      end

      # TODO
      #  - backtick 쌍이 맞지 않다는 오류 내보내기
      #  - backtick 문자 바로 앞 문자가 escape 문자인 경우
      #    해당 backtick은 인라인 코드 토큰 만들기 연산에서 제외하기
      if backtick_idx_list.size % 2 != 0
      end

      merged_tokens = []
      start = 0
      backtick_idx_list.each_slice(2).with_index do |pair|
        # 현재 backtick 쌍에 대해서
        #  backtick 쌍으로 둘러싸인 영역 왼쪽에 있는 토큰은 그대로 둔다
        no_code_left = tokens_array[start...pair[0]]

        #  backtick 안쪽에 있는 토큰을 CODE 타입 토큰 하나로 합친다
        inline_code = Token.new(
          type: 'CODE',
          value: tokens_array[pair[0]+1...pair[1]].map {|t| t.value}.join
        )
        merged_tokens << no_code_left << inline_code
        start = pair[1] + 1
      end
      no_code_right = tokens_array[backtick_idx_list[backtick_idx_list.size - 1]+1..-1]

      # 남은 토큰은 그대로 둔다
      merged_tokens << no_code_right
      merged_tokens.flatten
    end

    def self.merge_chars2escape(tokens_array)
      merged_tokens = []
      tokens_array.each.with_index do |token, idx|
        if idx != 0 and tokens_array[idx - 1].type == 'ESCAPE'
          next
        end

        if token.type == 'ESCAPE'
          merged_tokens <<  Tokenizer::Token.new(type: 'TEXT', value: tokens_array[idx + 1].value)
        else
          merged_tokens << token
        end
      end
      merged_tokens
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
