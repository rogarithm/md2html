module Md2Html
  module Tokenizer
    class TokenList
      include Enumerable

      attr_reader :tokens
      def initialize(tokens)
        @tokens = tokens
      end

      def each(&block)
        tokens.each(&block)
      end

      def peek(*expected_token_type_sequence)
        expected_token_type_sequence.each_with_index do |token_type, index|
          return false if tokens.empty?
          return false if token_type != tokens[index].type
        end
        true
      end

      def peek_or(*expected_token_type_sequences)
        expected_token_type_sequences.each do |token_type_sequence|
          return true if peek(*token_type_sequence)
        end
        false
      end

      def peek_from(index, *expected_token_type_sequence)
        return offset(index).peek(*expected_token_type_sequence)
      end

      def peek_until(stt_token_type, end_token_type)
        stt_index = tokens.find_index {|t| t.type == stt_token_type}
        end_index = tokens.find_index {|t| t.type == end_token_type}

        return nil if stt_index == nil or end_index == nil
        return nil if stt_index == nil and end_index == nil and end_index - stt_index == 1

        TokenList.new(tokens[stt_index+1..end_index-1])
      end

      def grab!(amount)
        raise "Invalid amount requested" if amount > tokens.length
        tokens.shift(amount)
      end

      def offset(index)
        return self if index.zero?
        TokenList.new(tokens[index..-1])
      end

      def values
        self.tokens.map {|t| t.value}.join
      end

      def has_no_token
        tokens.size == 0
      end

      def size
        tokens.size
      end

      def second
        tokens[1]
      end

      def third
        tokens[2]
      end

      def to_s
        "[\n\t#{tokens.map(&:to_s).join(",\n\t")}\n]"
      end
    end
  end
end
