require_relative "inline_parser"
require_relative "bold_parser"
require_relative "emphasis_parser"
require_relative "sentence_parser"
require_relative "text_parser"
require_relative "block_parser"
require_relative "paragraph_parser"
require_relative "sentences_and_eof_parser"
require_relative "sentences_and_newline_parser"
require_relative "body_parser"
require_relative "dash_parser"
require_relative "list_parser"
require_relative "list_item_parser"
require_relative "list_items_and_newline_parser"
require_relative "list_items_and_eof_parser"

module Md2Html
  module Parser
    class ParserFactory
      PARSERS = {
        inline_parser:                 InlineParser,
        bold_parser:                   BoldParser,
        emphasis_parser:               EmphasisParser,
        text_parser:                   TextParser,
        sentence_parser:               SentenceParser,
        block_parser:                  BlockParser,
        paragraph_parser:              ParagraphParser,
        sentences_and_eof_parser:      SentencesAndEofParser,
        sentences_and_newline_parser:  SentencesAndNewlineParser,
        body_parser:                   BodyParser,
        dash_parser:                   DashParser,
        list_parser:                   ListParser,
        list_item_parser:              ListItemParser,
        list_items_and_newline_parser: ListItemsAndNewlineParser,
        list_items_and_eof_parser:     ListItemsAndEofParser
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
