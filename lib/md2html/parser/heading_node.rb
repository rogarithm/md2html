module Md2Html
  module Parser
    class HeadingNode
      attr_reader :type, :sentences, :consumed
      def initialize(type:, sentences:, consumed:)
        @type = type
        @sentences = sentences
        @consumed  = consumed
      end

      def to_s
        if self.sentences.size < 1
          return 'EMPTY HEADING'
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
