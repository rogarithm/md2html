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

  it "peek_or() dash" do
    token_list = Md2Html::Tokenizer::tokenize('-')
    expect(token_list.peek_or(%w(DASH))).to eq true
  end

  it "peek_from() needs token position to check" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_from(1, 'TEXT')).to eq true
    expect(token_list.peek_from(2, 'UNDERSCORE')).to eq true
  end

  it "can put over 1 token to peek_from()" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_from(1, 'TEXT', 'UNDERSCORE')).to eq true
  end

  it "grab() picks tokens of smaller count than total token count" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    grabbed = token_list.grab!(2)
    expect(grabbed[0].type).to eq 'UNDERSCORE'
    expect(grabbed[0].value).to eq '_'
    expect(grabbed[1].type).to eq 'TEXT'
    expect(grabbed[1].value).to eq 'Foo'
  end

  it "grab raise error when token count exceeds total token count" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect { token_list.grab!(5) }.to raise_error(RuntimeError) # _Foo_ has 5 tokens, the last of which is EOF.
  end

  it "offset() returns new tokenlist starts from nth token" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    n = 1
    expect(token_list.offset(n).tokens[0].value).to eq 'Foo'
    expect(token_list.offset(n).tokens[1].value).to eq '_'
    expect(token_list.offset(n).tokens[2].value).to eq ''
  end
end
