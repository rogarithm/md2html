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

  it "peek_or()은 토큰 리스트와 순서가 맞는 토큰 타입이 입력으로 적어도 한 개 이상 주어지면 true를 반환한다" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_or(%w(UNDERSCORE))).to eq true
    expect(token_list.peek_or(%w(UNDERSCORE TEXT))).to eq true
  end

  it "peek_or()은 토큰 리스트에 있는 토큰 타입이더라도 순서가 맞지 않게 주어지면 false를 반환한다" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_or(%w(TEXT))).to eq false
  end

  it "peek_or()에 주어진 문자열 리스트 중 토큰 리스트와 순서가 맞는 리스트가 있다면 true를 반환한다" do
    token_list = Md2Html::Tokenizer::tokenize('_Foo_')
    expect(token_list.peek_or(%w(TEXT), %w(UNDERSCORE TEXT UNDERSCORE))).to eq true
    expect(token_list.peek_or(%w(UNDERSCORE TEXT UNDERSCORE), %w(TEXT))).to eq true
  end

  it "peek_or() for list item whose text has dash char" do
    list_item_tokens = Md2Html::Tokenizer::tokenize("- fo-o\n")
    list_item_tokens.peek_or(%w(DASH TEXT NEWLINE))
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

  it "peek_until()은 첫 입력에 매칭되는 토큰 다음부터 두번째 입력에 매칭되는 토큰이 나오기 전까지의 모든 토큰을 모은다" do
    token_list = Md2Html::Tokenizer::tokenize("- execute ssh-agent process, and register private key to ssh-agent
")
    expect(token_list.peek_until('LIST_MARK', ['NEWLINE']).collect {|x| [x.value]}.flatten!).to eq(
      [" execute ssh", "-", "agent process, and register private key to ssh", "-", "agent"]
    )
  end

  it "peek_until()은 두번째 입력으로 여러 토큰을 받을 수 있다" do
    token_list = Md2Html::Tokenizer::tokenize("- execute ssh-agent process, and register private key to ssh-agent")
    expect(token_list.peek_until('LIST_MARK', ['NEWLINE', 'EOF']).collect {|x| [x.value]}.flatten!).to eq(
      [" execute ssh", "-", "agent process, and register private key to ssh", "-", "agent"]
    )
  end

  it "values()는 자신이 갖고있는 모든 토큰의 value를 합친다" do
    token_list = Md2Html::Tokenizer::tokenize(
      "- execute ssh-agent process, and register private key to ssh-agent"
    )

    expect(token_list.values).to eq(
      "- execute ssh-agent process, and register private key to ssh-agent"
    )
  end
end
