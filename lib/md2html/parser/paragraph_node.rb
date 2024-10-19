module Md2Html
  module Parser
    class ParagraphNode
      attr_reader :type, :sentences, :consumed
      def initialize(sentences:, consumed:)
        @type = 'PARAGRAPH'
        @sentences = sentences
        @consumed  = consumed
      end

      def to_s
        if self.sentences.size < 1
          return 'EMPTY PARAGRAPH'
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
