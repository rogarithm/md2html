module Md2Html
  module Parser
    class SentenceNode
      attr_reader :words, :consumed, :type
      def initialize(words:, consumed:)
        @words = words
        @consumed  = consumed
        @type = 'SENTENCE'
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
