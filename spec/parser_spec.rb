require_relative '../lib/md2html/parser'
require_relative '../lib/md2html/tokenizer'
Dir.glob('./lib/md2html/parser/*.rb').each do |file|
  require file
end
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

def tokenize string
  Md2Html::Tokenizer::tokenize string
end

def create_parser name
  Md2Html::Parser::ParserFactory.build(name)
end

def create_node attrs
  Md2Html::Parser::Node.new attrs
end

def create_sentence_node attrs
  Md2Html::Parser::SentenceNode.new attrs
end

def create_paragraph_node attrs
  Md2Html::Parser::ParagraphNode.new attrs
end

def create_list_node attrs
  Md2Html::Parser::ListNode.new attrs
end

def create_body_node attrs
  Md2Html::Parser::BodyNode.new attrs
end

def parse tokens
  Md2Html::Parser::parse tokens
end

describe Md2Html::Parser, "parser" do

  context "inline parser" do
    it "can parse tokens that has bold tag" do
      parser = create_parser(:inline_parser)

      bold_token = tokenize("**foo**")
      expect(parser.match(bold_token)).to eq_node(create_node(type: 'BOLD', value: bold_token.third.value, consumed: 5))
    end

    it "can parse tokens that has emphasis tag" do
      parser = create_parser(:inline_parser)

      emphasis_token = tokenize("*foo*")
      expect(parser.match(emphasis_token)).to eq_node(create_node(type: 'EMPHASIS', value: emphasis_token.second.value, consumed: 3))
    end

    it "can parse tokens that has dash tag" do
      parser = create_parser(:inline_parser)

      dash_token = tokenize("-")
      expect(parser.match(dash_token)).to eq_node(create_node(type: 'DASH', value: dash_token.first.value, consumed: 1))
    end
  end

  context "list items parser" do
    it "can parse list item ends with eof" do
      parser = create_parser(:list_items_parser)

      list_nl_eof_token = tokenize("- foo\n")
      expect(parser.match(list_nl_eof_token)).to eq_list_node(
        create_list_node(
          sentences: [
            create_node(type: 'LIST_ITEM', value: ' foo', consumed: 3)
          ],
          consumed: 4)
      )
    end

    it "can parse list items ends with two newlines and eof" do
      parser = create_parser(:list_items_parser)

      list_nl_nl_eof_token = tokenize("- foo\n\n")
      expect(parser.match(list_nl_nl_eof_token)).to eq_list_node(
        create_list_node(
          sentences: [
            create_node(type: 'LIST_ITEM', value: ' foo', consumed: 3)
          ],
          consumed: 5)
      )
    end

    it "can parse multiple list items ends with eof or newline" do
      parser = create_parser(:list_items_parser)

      list_nl_list_nl_eof_token = tokenize("- foo\n- bar\n")
      expect(parser.match(list_nl_list_nl_eof_token)).to eq_list_node(
        create_list_node(
          sentences: [
            create_node(type: 'LIST_ITEM', value: ' foo', consumed: 3),
            create_node(type: 'LIST_ITEM', value: ' bar', consumed: 3)
          ],
          consumed: 7)
      )
    end
  end

  context "sentence parser" do
    it "can parse one sentence without eof in mind" do
      parser = create_parser(:sentence_parser)
      expected_words = [
        create_node(type: 'BOLD', value: 'Foo', consumed: 5),
        create_node(type: 'TEXT', value: ' and ', consumed: 1),
        create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
        create_node(type: 'TEXT', value: '.', consumed: 1)
      ]

      nl_token = tokenize("__Foo__ and *text*.\n")
      sentence_node = parser.match(nl_token)
      expect(sentence_node).to eq_sentence_node create_sentence_node(words: expected_words, consumed: 12)

      nl_nl_token = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = parser.match(nl_nl_token)
      expect(sentence_node).to eq_sentence_node create_sentence_node(words: expected_words, consumed: 13)
    end

    it "can parse one sentence with eof in mind" do
      parser = create_parser(:sentence_parser)
      expected_words = [
        create_node(type: 'BOLD', value: 'Foo', consumed: 5),
        create_node(type: 'TEXT', value: ' and ', consumed: 1),
        create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
        create_node(type: 'TEXT', value: '.', consumed: 1)
      ]

      token_no_nl = tokenize("__Foo__ and *text*.")
      sentence_node = parser.match(token_no_nl)
      expect(sentence_node).to eq_sentence_node create_sentence_node(words: expected_words, consumed: 11)

      token_nl = tokenize("__Foo__ and *text*.\n")
      sentence_node = parser.match(token_nl)
      expect(sentence_node).to eq_sentence_node create_sentence_node(words: expected_words, consumed: 12)

      token_nl_nl = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = parser.match(token_nl_nl)
      expect(sentence_node).to eq_sentence_node create_sentence_node(words: expected_words, consumed: 13)
    end
  end

  context "paragraph parser" do
    it "can parse paragraph" do
      parser = create_parser(:paragraph_parser)

      tokens = tokenize("__Foo__ and *text*.\n**Foo** and *text*.")
      paragraph_node = parser.match(tokens)
      expect(paragraph_node).to eq_paragraph_node create_paragraph_node(
        sentences: [
          create_sentence_node(words: [
            create_node(type: 'BOLD', value: 'Foo', consumed: 5),
            create_node(type: 'TEXT', value: ' and ', consumed: 1),
            create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
            create_node(type: 'TEXT', value: '.', consumed: 1),
            create_node(type: 'NEWLINE', value: '\n', consumed: 2)
          ], consumed: 12),
          create_sentence_node(words: [
            create_node(type: 'BOLD', value: 'Foo', consumed: 5),
            create_node(type: 'TEXT', value: ' and ', consumed: 1),
            create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
            create_node(type: 'TEXT', value: '.', consumed: 1)
          ], consumed: 10),
        ],
        consumed: 22
      )
    end
  end

  it "heading parser parse text that has hash character" do
    parser = create_parser(:heading_parser)

    tokens = tokenize("# title\n")
    node = parser.match(tokens)

    expect(node).to eq_node(
      create_node(type: 'HEADING', value: ' title', consumed: 3)
    )
  end

  it "block parser parse text that has dash character" do
    parser = create_parser(:block_parser)

    tokens = tokenize("- foo")
    paragraph_node = parser.match(tokens)

    expect(paragraph_node.consumed).to eq 3
  end

  it "body parser parse text that has dash character" do
    parser = create_parser(:body_parser)

    tokens = tokenize("- foo")
    paragraph_node = parser.match(tokens)

    expect(paragraph_node.consumed).to eq 3
  end

  context "with parser chain" do
    it "can parse text that has dash character" do
      tokens = tokenize("- foo")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 3
    end

    it "can parse 1 list item and newline" do
      tokens = tokenize("- foo\n")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 4
    end

    it "can parse list items of the same level" do
      tokens = tokenize("- foo\n- bar\n- baz\n")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 10 #(dash text newline) * 3 + eof
    end

    it "can parse plain paragraph and list items of the same level" do
      tokens = tokenize("- foo\n- bar\n- baz\n\n__Foo__ and *text*.\nAnother para.")
      nodes = parse(tokens)

      expect(nodes).to eq_body_node(
        create_body_node(
          blocks:[
            create_list_node(
              sentences: [
                create_node(type: 'LIST_ITEM', value: ' foo', consumed: 3),
                create_node(type: 'LIST_ITEM', value: ' bar', consumed: 3),
                create_node(type: 'LIST_ITEM', value: ' baz', consumed: 3),
              ],
              consumed: 10
            ),
            create_paragraph_node(
              sentences: [
                create_sentence_node(words: [
                  create_node(type: 'BOLD', value: 'Foo', consumed: 5),
                  create_node(type: 'TEXT', value: ' and ', consumed: 1),
                  create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
                  create_node(type: 'TEXT', value: '.', consumed: 1),
                  create_node(type: 'NEWLINE', value: '\n', consumed: 2)
                ], consumed: 12),
                create_sentence_node(words: [
                  create_node(type: 'TEXT', value: 'Another para.', consumed: 1),
                ], consumed: 1),
              ],
              consumed: 13
            )
          ],
          consumed: 23
        )
      )
    end
  end
end
