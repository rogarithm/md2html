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

describe Md2Html::Parser, "parser" do

  it "can parse tokens that has bold tag" do
    parser = Md2Html::Parser::ParserFactory.build(:inline_parser)

    bold_token = Md2Html::Tokenizer::tokenize("**foo**")
    expect(parser.match(bold_token)).to eq_node(Md2Html::Parser::Node.new(type: 'BOLD', value: bold_token.third.value, consumed: 5))
  end

  it "can parse tokens that has emphasis tag" do
    parser = Md2Html::Parser::ParserFactory.build(:inline_parser)

    emphasis_token = Md2Html::Tokenizer::tokenize("*foo*")
    expect(parser.match(emphasis_token)).to eq_node(Md2Html::Parser::Node.new(type: 'EMPHASIS', value: emphasis_token.second.value, consumed: 3))
  end

  it "can parse tokens that has dash tag" do
    parser = Md2Html::Parser::ParserFactory.build(:inline_parser)

    dash_token = Md2Html::Tokenizer::tokenize("-")
    expect(parser.match(dash_token)).to eq_node(Md2Html::Parser::Node.new(type: 'DASH', value: dash_token.first.value, consumed: 1))
  end

  it "can parse list items ends with newline and eof" do
    parser = Md2Html::Parser::ParserFactory.build(:list_items_parser)

    list_nl_eof_token = Md2Html::Tokenizer::tokenize("- foo\n")
    expect(parser.match(list_nl_eof_token)).to eq_list_node(
      Md2Html::Parser::ListNode.new(
        sentences: Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' foo', consumed: 3),
        consumed: 4)
    )
  end

  it "can parse list items ends with two newlines and eof" do
    parser = Md2Html::Parser::ParserFactory.build(:list_items_parser)

    list_nl_nl_eof_token = Md2Html::Tokenizer::tokenize("- foo\n\n")
    expect(parser.match(list_nl_nl_eof_token)).to eq_list_node(
      Md2Html::Parser::ListNode.new(
        sentences: Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' foo', consumed: 3),
        consumed: 5)
    )
  end

  it "can parse multiple list items ends with eof or newline" do
    parser = Md2Html::Parser::ParserFactory.build(:list_items_parser)

    list_nl_list_nl_eof_token = Md2Html::Tokenizer::tokenize("- foo\n- bar\n")
    expect(parser.match(list_nl_list_nl_eof_token)).to eq_list_node(
      Md2Html::Parser::ListNode.new(
        sentences: [
          Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' foo', consumed: 3),
          Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' bar', consumed: 3)
        ],
        consumed: 8)
    )
  end

  it "can parse one sentence without eof in mind" do
    parser = Md2Html::Parser::ParserFactory.build(:sentence_parser)
    expected_sentence = [
      Md2Html::Parser::Node.new(type: 'BOLD', value: 'Foo', consumed: 5),
      Md2Html::Parser::Node.new(type: 'TEXT', value: ' and ', consumed: 1),
      Md2Html::Parser::Node.new(type: 'EMPHASIS', value: 'text', consumed: 3),
      Md2Html::Parser::Node.new(type: 'TEXT', value: '.', consumed: 1)
    ]

    nl_token = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.\n")
    paragraph_node = parser.match(nl_token)
    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: expected_sentence, consumed: 12)

    nl_nl_token = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.\n\n")
    paragraph_node = parser.match(nl_nl_token)
    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: expected_sentence, consumed: 13)
  end

  it "can parse one sentence with eof in mind" do
    parser = Md2Html::Parser::ParserFactory.build(:sentence_parser)
    expected_sentence = [
      Md2Html::Parser::Node.new(type: 'BOLD', value: 'Foo', consumed: 5),
      Md2Html::Parser::Node.new(type: 'TEXT', value: ' and ', consumed: 1),
      Md2Html::Parser::Node.new(type: 'EMPHASIS', value: 'text', consumed: 3),
      Md2Html::Parser::Node.new(type: 'TEXT', value: '.', consumed: 1)
    ]

    token_no_nl = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.")
    paragraph_node = parser.match(token_no_nl)
    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: expected_sentence, consumed: 11)

    token_nl = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.\n")
    paragraph_node = parser.match(token_nl)
    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: expected_sentence, consumed: 12)

    token_nl_nl = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.\n\n")
    paragraph_node = parser.match(token_nl_nl)
    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: expected_sentence, consumed: 13)
  end

    expect(paragraph_node).to eq_paragraph_node Md2Html::Parser::ParagraphNode.new(sentences: [
    Md2Html::Parser::Node.new(type: 'BOLD', value: 'Foo', consumed: 5),
    Md2Html::Parser::Node.new(type: 'TEXT', value: ' and ', consumed: 1),
    Md2Html::Parser::Node.new(type: 'EMPHASIS', value: 'text', consumed: 3),
    Md2Html::Parser::Node.new(type: 'TEXT', value: '.', consumed: 1)
    ], consumed: 13)
  end

  it "parse text that has dash character" do
    tokens = Md2Html::Tokenizer::tokenize("- foo")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 3
  end

  it "parse 1 list item and newline" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 4
  end

  it "parse list items of the same level" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n- bar\n- baz\n")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 10 #(dash text newline) * 3 + eof
  end

  it "parse plain paragraph and list items of the same level" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n- bar\n- baz\n\n__Foo__ and *text*.\nAnother para.")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 23
  end
end
