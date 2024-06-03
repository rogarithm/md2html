module Md2Html
  module Parser
    class ListNode
      attr_reader :sentences, :consumed, :type
      def initialize(sentences:, consumed:)
        @sentences = sentences
        @consumed  = consumed
        @type = 'LIST'
      end

      def to_s
        if self.sentences.size < 1
          return 'EMPTY LIST'
        end
        result = "#{self.type}:#{self.consumed}\n"
        self.sentences.each do |sentence|
          result += "  #{sentence.to_s}\n"
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
