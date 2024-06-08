require_relative '../lib/md2html/tokenizer'
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

describe Md2Html::Tokenizer do
  it "tokenize text" do
    tokens = Md2Html::Tokenizer::tokenize('Hi')

    expect(tokens).to eq_token_list(Md2Html::Tokenizer::TokenList.new(
      [Md2Html::Tokenizer::Token.new(type: 'TEXT', value: 'Hi'),
       Md2Html::Tokenizer::Token.end_of_file]
    ))
  end

  it "tokenize text with underscores" do
    tokens = Md2Html::Tokenizer::tokenize('_Foo_')

    expect(tokens.first.type).to eq 'UNDERSCORE'
    expect(tokens.first.value).to eq '_'

    expect(tokens.second.type).to eq 'TEXT'
    expect(tokens.second.value).to eq 'Foo'

    expect(tokens.third.type).to eq 'UNDERSCORE'
    expect(tokens.third.value).to eq '_'
  end

  it "tokenize paragraph" do
    tokens = Md2Html::Tokenizer::tokenize("Hello, World!
This is a _quite_ **long** text for what we've been testing so far.

And this is another para.")
    #puts tokens
    expect(true).to eq true
  end

  it "tokenize text with dash" do
    tokens = Md2Html::Tokenizer::tokenize('- first item')

    expect(tokens.first.type).to eq 'DASH'
    expect(tokens.first.value).to eq '-'

    expect(tokens.second.type).to eq 'TEXT'
    expect(tokens.second.value).to eq ' first item'
  end

  it "can make token of hash character" do
    tokens = Md2Html::Tokenizer::tokenize('# heading level 1')

    expect(tokens.first.type).to eq 'HASH'
    expect(tokens.first.value).to eq '#'

    expect(tokens.second.type).to eq 'TEXT'
    expect(tokens.second.value).to eq ' heading level 1'
  end
end
