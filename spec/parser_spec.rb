require_relative '../lib/md2html/parser'
Dir.glob('./lib/md2html/parser/*.rb').each do |file|
  require file
end
require 'pry'

describe Md2Html::Parser do
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
    parser = Md2Html::Parser::ParserFactory.build(:list_items_and_eof_parser)
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
