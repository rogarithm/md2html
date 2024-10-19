require_relative '../lib/md2html/tokenizer'
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

def tokenize plain_text
  Md2Html::Tokenizer::tokenize plain_text
end

def tokens_as_array plain_text
  Md2Html::Tokenizer::tokens_as_array plain_text
end

def merge_chars2escape plain_text
  Md2Html::Tokenizer::merge_chars2escape plain_text
end

def create_token attrs
  Md2Html::Tokenizer::Token.new attrs
end

def create_eof_token
  Md2Html::Tokenizer::Token.end_of_file
end

def create_token_list tokens
  Md2Html::Tokenizer::TokenList.new tokens
end

describe Md2Html::Tokenizer do
  it "tokenize text" do
    tokens = tokenize('Hi')

    expect(tokens.collect {|x| [x.type, x.value]}).to eq(
      [['TEXT', 'Hi'], ['EOF', '']]
    )
  end

  it "tokenize text with underscores" do
    tokens = tokenize('_Foo_')

    expect(tokens.collect {|x| [x.type, x.value]}).to eq(
      [['UNDERSCORE', '_'], ['TEXT', 'Foo'], ['UNDERSCORE', '_'], ['EOF', '']]
    )
  end

  it "tokenize paragraph" do
    tokens = tokenize("Hello, World!
This is a _quite_ **long** text for what we've been testing so far.

And this is another para.")

    expect(tokens.collect { |x| [x.type, x.value] }).to eq([
      ['TEXT', 'Hello, World!'], ['NEWLINE', "\n"],
      ['TEXT', 'This is a '], ['UNDERSCORE', '_'], ['TEXT', 'quite'],
      ['UNDERSCORE', '_'], ['TEXT', ' '], ['STAR', '*'], ['STAR', '*'],
      ['TEXT', 'long'], ['STAR', '*'], ['STAR', '*'],
      ['TEXT', ' text for what we\'ve been testing so far.'],
      ['NEWLINE', "\n"], ['NEWLINE', "\n"], ['TEXT', 'And this is another para.'],
      ['EOF', '']
    ])
  end

  it "tokenize text with dash" do
    tokens = tokenize('- first item')

    expect(tokens.collect {|x| [x.type, x.value]}).to eq(
      [['DASH', '-'], ['TEXT', ' first item'], ['EOF', '']]
    )
  end

  it "can make token of hash character" do
    tokens = tokenize('# heading level 1')

    expect(tokens.collect {|x| [x.type, x.value]}).to eq([
      ['HASH', '#'], ['TEXT', ' heading level 1'], ['EOF', '']
    ])
  end

  it "can make token of multiple hash character" do
    tokens = tokenize('## heading level 2')

    expect(tokens.collect {|x| [x.type, x.value]}).to eq([
      ['HASH', '#'], ['HASH', '#'], ['TEXT', ' heading level 2'], ['EOF', '']
    ])
  end

  it "can make token of non-special char when backslash exists before the char" do
    token_lists = ['\-', '\#', '\_', '\*'].collect{|w| tokens_as_array(w)}
    expect(token_lists.collect {|x| x.collect {|x| [x.type, x.value]}}).to eq(
      [
        [["ESCAPE", "\\"], ["DASH", "-"], ["EOF", ""]],
        [["ESCAPE", "\\"], ["HASH", "#"], ["EOF", ""]],
        [["ESCAPE", "\\"], ["UNDERSCORE", "_"], ["EOF", ""]],
        [["ESCAPE", "\\"], ["STAR", "*"], ["EOF", ""]]
      ]
    )
  end

  it "tokens_as_array() merges escape char and trailing special char" do
    token_list = tokens_as_array('\-')

    expect(
      merge_chars2escape(token_list).collect {|x| [x.type, x.value]}
    ).to eq(
      [["TEXT", "-"], ["EOF", ""]]
    )
  end
end
