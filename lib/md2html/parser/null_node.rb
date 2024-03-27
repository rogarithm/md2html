
module Md2Html
  module Parser
    class NullNode
      def null?
        true
      end

      def present?
        false
      end
    end
  end
end
