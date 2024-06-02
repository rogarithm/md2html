require_relative "inline_parser"
require_relative "sentence_element_parser"
require_relative "sentence_parser"
require_relative "text_parser"
require_relative "block_parser"
require_relative "paragraph_parser"
require_relative "body_parser"
require_relative "list_parser"
require_relative "list_item_parser"
require_relative "list_items_parser"

module Md2Html
  module Parser
    class ParserFactory
      PARSERS = {
        inline_parser:                 InlineParser,
        text_parser:                   TextParser,
        sentence_element_parser:       SentenceElementParser,
        sentence_parser:               SentenceParser,
        block_parser:                  BlockParser,
        paragraph_parser:              ParagraphParser,
        body_parser:                   BodyParser,
        list_parser:                   ListParser,
        list_item_parser:              ListItemParser,
        list_items_parser:             ListItemsParser,
      }.freeze

      def self.build(name, *args, &block)
        parser = PARSERS.fetch(name.to_sym) { raise "Invalid parser name: #{name}" }
        cache[parser] = parser.new(*args, &block) if cache[parser].nil?
        cache[parser]
      end

      def self.cache
        @@cache ||= {}
      end
    end
  end
end
