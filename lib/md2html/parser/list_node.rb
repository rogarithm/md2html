
module Md2Html
  module Parser
    class ListNode
      attr_reader :sentences, :consumed, :type
      def initialize(sentences:, consumed:)
        @sentences = sentences
        @consumed  = consumed
        @type = 'LIST'
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
