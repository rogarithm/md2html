module Md2Html
  module Parser
    class SentenceNode
      attr_reader :words, :consumed, :type
      def initialize(words:, consumed:)
        @words = words
        @consumed  = consumed
        @type = 'SENTENCE'
      end

      def to_s
        if self.words.size < 1
          return 'EMPTY SENTENCE'
        end
        result = "#{self.type}:#{self.consumed}\n"
        self.words.each do |word|
          result += "  #{word.to_s}\n"
        end
        result
      end

      def present?
        true
      end

      def null?
        false
      end
    end
  end
end
