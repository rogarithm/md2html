# A "null token". Follows the Nullable Object Pattern.

module Md2Html
  module Tokenizer
    class NullToken
      def null?
        true
      end

      def present?
        false
      end
    end
  end
end
