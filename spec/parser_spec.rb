require_relative '../lib/md2html/parser'
Dir.glob('./lib/md2html/parser/*.rb').each do |file|
  require file
end
require 'pry'
require_relative './helpers/spec_helper'

describe Md2Html::Parser do

  it "inline_parser can parse bold, emphasis, dash element, which are inline elements" do
    parser = Md2Html::Parser::ParserFactory.build(:inline_parser)

    bold_token = Md2Html::Tokenizer::tokenize("**foo**")
    expect(parser.match(bold_token)).to eq_node(Md2Html::Parser::Node.new(type: 'BOLD', value: bold_token.third.value, consumed: 5))

    emphasis_token = Md2Html::Tokenizer::tokenize("*foo*")
    expect(parser.match(emphasis_token)).to eq_node(Md2Html::Parser::Node.new(type: 'EMPHASIS', value: emphasis_token.second.value, consumed: 3))

    dash_token = Md2Html::Tokenizer::tokenize("-")
    expect(parser.match(dash_token)).to eq_node(Md2Html::Parser::Node.new(type: 'DASH', value: dash_token.first.value, consumed: 1))
  end

  it "list_items_parser can parse list items ends with eof or newline" do
    parser = Md2Html::Parser::ParserFactory.build(:list_items_parser)

    list_nl_eof_token = Md2Html::Tokenizer::tokenize("- foo\n")
    expect(parser.match(list_nl_eof_token)).to eq_list_node(
      Md2Html::Parser::ListNode.new(
        sentences: Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' foo', consumed: 3),
        consumed: 4)
    )

    list_nl_nl_eof_token = Md2Html::Tokenizer::tokenize("- foo\n\n")
    expect(parser.match(list_nl_nl_eof_token)).to eq_list_node(
      Md2Html::Parser::ListNode.new(
        sentences: Md2Html::Parser::Node.new(type: 'LIST_ITEM', value: ' foo', consumed: 3),
        consumed: 5)
    )

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

  it "makes node from markdown content" do
    tokens = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.\nAnother para.")
    body_node = Md2Html::Parser::parse(tokens)
    expect(body_node.consumed).to eq 13
  end

  it "parse text that has dash character" do
    tokens = Md2Html::Tokenizer::tokenize("- foo")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 3
  end

  it "list_item_parser parse one list item" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n")
    parser = Md2Html::Parser::ParserFactory.build(:list_item_parser)
    nodes = parser.match(tokens)
    expect(nodes.consumed).to eq 3
  end

  it "parse 1 list item and newline" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n")
    nodes = Md2Html::Parser::parse(tokens)
    expect(nodes.consumed).to eq 4
  end

  it "list_items_and_eof_parser parse list items of the same level" do
    tokens = Md2Html::Tokenizer::tokenize("- foo\n- bar\n- baz\n")
    parser = Md2Html::Parser::ParserFactory.build(:list_items_parser)
    nodes = parser.match(tokens)
    expect(nodes.consumed).to eq 10 #(dash text newline) * 3 + eof
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
