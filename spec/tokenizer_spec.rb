require_relative '../lib/md2html/tokenizer'
require 'pry'

describe Md2Html::Tokenizer do
  it "tokenize text" do
    tokens = Md2Html::Tokenizer::tokenize('Hi')
    expect(tokens.first.type).to eq 'TEXT'
    expect(tokens.first.value).to eq 'Hi'
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

  it "tokenize text with hash char" do
    tokens = Md2Html::Tokenizer::tokenize('### section')

    expect(tokens.first.type).to eq 'HASH'
    expect(tokens.first.value).to eq '#'

    expect(tokens.second.type).to eq 'HASH'
    expect(tokens.second.value).to eq '#'

    expect(tokens.nth(4).type).to eq 'TEXT'
    expect(tokens.nth(4).value).to eq ' section'
  end
end
