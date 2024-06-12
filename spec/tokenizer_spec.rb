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

    expect(tokens).to eq_token_list(create_token_list(
      [create_token(type: 'TEXT', value: 'Hi'),
       create_eof_token]
    ))
  end

  it "tokenize text with underscores" do
    tokens = tokenize('_Foo_')

    expect(tokens).to eq_token_list(create_token_list(
      [create_token(type: 'UNDERSCORE', value: '_'),
       create_token(type: 'TEXT', value: 'Foo'),
       create_token(type: 'UNDERSCORE', value: '_'),
       create_eof_token]
    ))
  end

  it "tokenize paragraph" do
    tokens = tokenize("Hello, World!
This is a _quite_ **long** text for what we've been testing so far.

And this is another para.")

    expect(tokens).to eq_token_list(create_token_list([
      create_token(type: 'TEXT', value: 'Hello, World!'),
      create_token(type: 'NEWLINE', value: "\n"),
      create_token(type: 'TEXT', value: 'This is a '),
      create_token(type: 'UNDERSCORE', value: '_'),
      create_token(type: 'TEXT', value: 'quite'),
      create_token(type: 'UNDERSCORE', value: '_'),
      create_token(type: 'TEXT', value: ' '),
      create_token(type: 'STAR', value: '*'),
      create_token(type: 'STAR', value: '*'),
      create_token(type: 'TEXT', value: 'long'),
      create_token(type: 'STAR', value: '*'),
      create_token(type: 'STAR', value: '*'),
      create_token(type: 'TEXT', value: ' text for what we\'ve been testing so far.'),
      create_token(type: 'NEWLINE', value: "\n"),
      create_token(type: 'NEWLINE', value: "\n"),
      create_token(type: 'TEXT', value: 'And this is another para.'),
      create_eof_token
    ]))
  end

  it "tokenize text with dash" do
    tokens = tokenize('- first item')

    expect(tokens).to eq_token_list(create_token_list([
      create_token(type: 'DASH', value: '-'),
      create_token(type: 'TEXT', value: ' first item'),
      create_eof_token
    ]))
  end

  it "can make token of hash character" do
    tokens = tokenize('# heading level 1')

    expect(tokens).to eq_token_list(create_token_list([
      create_token(type: 'HASH', value: '#'),
      create_token(type: 'TEXT', value: ' heading level 1'),
      create_token(type: 'EOF', value: '')
    ]))
  end

  it "can make token of multiple hash character" do
    tokens = tokenize('## heading level 2')

    expect(tokens).to eq_token_list(create_token_list([
      create_token(type: 'HASH', value: '#'),
      create_token(type: 'HASH', value: '#'),
      create_token(type: 'TEXT', value: ' heading level 2'),
      create_token(type: 'EOF', value: '')
    ]))
  end
end
