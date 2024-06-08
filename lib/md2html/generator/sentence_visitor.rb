module Md2Html
  module Generator
    class SentenceVisitor
      SENTENCE_VISITORS = {
        "BOLD"     => ->(n) {"<strong>#{n.value}</strong>"},
        "EMPHASIS" => ->(n) {"<em>#{n.value}</em>"},
        "TEXT"     => ->(n) {"#{n.value}"},
        "DASH"     => ->(n) {"#{n.value}"},
        "NEWLINE"  => ->(n) {"<br>"}
      }.freeze

      def visit(sentence_node)
        sentence_node.words.map do |word|
          "#{visitor_for(word).call(word)}"
        end.join
      end

      private

      def visitor_for(word)
        SENTENCE_VISITORS.fetch(word.type) {
          error_msg = <<-msg.chomp
Invalid sentence node type!
It might be there's no sufficient visitor
for a character or markdown element to generate html.
If it's the case, consider add a new visitor for that.
  msg
  raise error_msg
        }
      end
    end
  end
end
