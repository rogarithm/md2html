module Md2Html
  module Parser
    class SentenceNode
      attr_reader :words, :consumed
      attr_accessor :type

      def initialize(options = {})
        @words = options[:words]
        @consumed  = options[:consumed]
        @type = options[:type] || 'SENTENCE'
      end

      def self.ends_early(options = {})
        sentence = SentenceNode.new(options)
        sentence.type = 'SENTENCE_ENDS_EARLY'
        sentence
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
