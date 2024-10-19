module Md2Html
  module Parser
    class BodyNode
      attr_reader :type, :blocks, :consumed
      def initialize(blocks:, consumed:)
        @type = 'BODY'
        @blocks = blocks
        @consumed  = consumed
      end

      def to_s
        self.blocks.each do |block|
          block.to_s
        end.join("\n")
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
