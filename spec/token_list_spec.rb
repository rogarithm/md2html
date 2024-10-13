require_relative '../lib/md2html/tokenizer'
Dir.glob('./lib/md2html/tokenizer/*.rb').each do |file|
  require file
end
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

describe Md2Html::Tokenizer::TokenList do
  it "peek() returns true only when given token types are in same order with given token list" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek('UNDERSCORE', 'TEXT', 'UNDERSCORE')).to eq true
    expect(token_list.peek('TEXT')).to eq false
    expect(token_list.peek('UNDERSCORE', 'UNDERSCORE', 'TEXT')).to eq false
  end

  it "peek_or() returns true when at least 1 matching token exists" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_or(%w(TEXT), %w(UNDERSCORE TEXT UNDERSCORE))).to eq true
    expect(token_list.peek_or(%w(UNDERSCORE TEXT UNDERSCORE), %w(TEXT))).to eq true
  end

  it "peek_or() returns true when given token types match in order, and only part of it" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_or(%w(TEXT))).to eq false
    expect(token_list.peek_or(%w(UNDERSCORE TEXT))).to eq true
  end

  it "peek_from() specifies the position of token to match" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_from(1, 'TEXT')).to eq true
    expect(token_list.peek_from(2, 'UNDERSCORE')).to eq true
  end

  it "can put over 1 token to peek_from()" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(
      token_list.peek_from(1, 'TEXT', 'UNDERSCORE')
    ).to eq true
  end

  it "grab() picks tokens of smaller count than total token count" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(
      token_list.grab!(2).collect {|x| [x.type, x.value]}
    ).to eq(
      [['UNDERSCORE', '_'], ['TEXT', 'Foo']]
    )
  end

  it "grab raise error when token count exceeds total token count" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect { token_list.grab!(5) }.to raise_error(RuntimeError) # _Foo_ has 4 tokens, the last of which is EOF.
  end

  it "offset() returns new tokenlist starts from nth token" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.offset(1).collect {|x| [x.value]}.flatten!).to eq(
      ['Foo', '_', '']
    )
  end
end
