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
      list_mark_checked_tokens = check_list_mark(escape_merged_tokens)
      Tokenizer::TokenList.new(list_mark_checked_tokens)
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
      if backtick_idx_list.size % 2 != 0
      end

      merged_tokens = []
      start = 0
      backtick_idx_list.each_slice(2).with_index do |pair|
        if pair[0] != 0 &&
          tokens_array[pair[0] - 1].type == 'ESCAPE' &&
          tokens_array[pair[1] - 1].type == 'ESCAPE'
          # 현재 backtick 쌍을 리터럴로 쓰려는 경우
          # 범위 안에 있는 토큰은 변환하지 않고 그대로 결과 토큰 리스트에 추가한다
          # TODO
          #  - backtick 쌍 안에 또다른 backtick 쌍이 있고,
          #  - 내부의 backtick 쌍을 리터럴로 쓰는 경우를 처리하지 못한다
          merged_tokens << tokens_array[start..pair[1]]
        else
          # 현재 backtick 쌍을 인라인 코드로 포맷팅하려는 경우
          #  backtick 쌍으로 둘러싸인 영역 왼쪽에 있는 토큰은 그대로 둔다
          no_code_left = tokens_array[start...pair[0]]

          #  backtick 안쪽에 있는 토큰을 CODE 타입 토큰 하나로 합친다
          inline_code = Token.new(
            type: 'CODE',
            value: tokens_array[pair[0]+1...pair[1]].map {|t| t.value}.join
          )
          merged_tokens << no_code_left << inline_code
        end
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

      merge_text_tokens = []
      group_text_tokens = []
      merged_tokens.each do |token|
        if token.type == 'TEXT'
          group_text_tokens << token
        end
        if token.type != 'TEXT'
          merge_text_tokens << Tokenizer::Token.new(
            type: 'TEXT', value: group_text_tokens.map {|t| t.value}.join
          ) if group_text_tokens != []
          merge_text_tokens << token
          group_text_tokens = []
        end
      end
      merge_text_tokens
    end

    def self.check_list_mark(tokens_array)
      result = []
      tokens_array.each.with_index do |token, idx|
        if idx == 0 and tokens_array[idx].type == "DASH"
          result << Tokenizer::Token.new(type: "LIST_MARK", value: "-")
          next
        end
        if idx != 0 and tokens_array[idx - 1].type == "NEWLINE" and tokens_array[idx].type == "DASH"
          result << Tokenizer::Token.new(type: "LIST_MARK", value: "-")
          next
        end
        result << tokens_array[idx]
      end
      result
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
