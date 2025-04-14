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

def merge_inline_code_chars plain_text
  Md2Html::Tokenizer::merge_inline_code_chars plain_text
end

def check_list_mark plain_text
  Md2Html::Tokenizer::check_list_mark plain_text
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
      [['LIST_MARK', '-'], ['TEXT', ' first item'], ['EOF', '']]
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

  it "can tokenize text that wrapped with backtick" do
    t1 = tokens_as_array('`foo = bar`')

    expect(t1.collect {|x| [x.type, x.value]}).to eq([
      ['BACKTICK', '`'], ['TEXT', 'foo = bar'], ['BACKTICK', '`'], ['EOF', '']
    ])

    t2 = tokens_as_array('`main> git status --short`')

    expect(t2.collect {|x| [x.type, x.value]}).to eq([
      ['BACKTICK', '`'],
      ['TEXT', 'main> git status '], ['DASH', '-'], ['DASH', '-'], ['TEXT', 'short'],
      ['BACKTICK', '`'],
      ['EOF', '']
    ])

    t3 = tokens_as_array('`M spec/source/draft_post.md`')

    expect(t3.collect {|x| [x.type, x.value]}).to eq([
      ['BACKTICK', '`'],
      ['TEXT', 'M spec/source/draft'], ["UNDERSCORE", "_"], ['TEXT', 'post.md'],
      ['BACKTICK', '`'],
      ['EOF', '']
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

    token_list = tokens_as_array('\-\-barbaz')

    expect(
      merge_chars2escape(token_list).collect { |x| [x.type, x.value] }
    ).to eq(
      [["TEXT", "--barbaz"], ["EOF", ""]]
    )

    token_list = tokens_as_array("foo - bar
\\*\\*foobar

\\-\\-barbaz

\\#foo")
    expect(
      merge_chars2escape(token_list).map{|t| [t.type, t.value]}
    ).to eq(
      [
        ["TEXT", "foo "], ["DASH", "-"], ["TEXT", " bar"], ["NEWLINE", "\n"],
        ["TEXT", "**foobar"], ["NEWLINE", "\n"], ["NEWLINE", "\n"],
        ["TEXT", "--barbaz"], ["NEWLINE", "\n"], ["NEWLINE", "\n"],
        ["TEXT", "#foo"], ["EOF", ""]
      ]
    )
  end

  it "merge_inline_code_chars() merges chars for inline code" do
    token_list = tokens_as_array('hi `foo = bar` there')

    expect(
      merge_inline_code_chars(token_list).collect {|x| [x.type, x.value]}
    ).to eq(
      [
        ["TEXT", "hi "], ["CODE", 'foo = bar'], ["TEXT", " there"], ["EOF", ""]
      ]
    )
  end

  it "merge_inline_code_chars() merges multiple set of chars for inline code" do
    token_list = tokens_as_array('hi `foo = bar` there and still here is some code: `main> git status --short`')

    expect(
      merge_inline_code_chars(token_list).collect {|x| [x.type, x.value]}
    ).to eq(
      [
        ["TEXT", "hi "], ["CODE", 'foo = bar'],
        ["TEXT", " there and still here is some code: "],
        ["CODE", 'main> git status --short'], ["EOF", ""]
      ]
    )
  end

  it "merge_inline_code_chars() ignores 1 escaped backtick pair" do
    token_list = tokens_as_array('\`ls\`')
    expect(
      merge_inline_code_chars(token_list).collect {|x| [x.type, x.value]}
    ).to eq(
      [
        ["ESCAPE", "\\"], ["BACKTICK", "`"],
        ["TEXT", "ls"], ["ESCAPE", "\\"],
        ["BACKTICK", "`"], ["EOF", ""]
      ]
    )
  end

  it "merge_inline_code_chars() ignores only escaped backtick pair" do
    token_list = tokens_as_array('\`ls\` `cat`')
    expect(
      merge_inline_code_chars(token_list).collect {|x| [x.type, x.value]}
    ).to eq(
      [
        ["ESCAPE", "\\"], ["BACKTICK", "`"],
        ["TEXT", "ls"], ["ESCAPE", "\\"],
        ["BACKTICK", "`"], ["TEXT", " "],
        ["CODE", 'cat'], ["EOF", ""]
      ]
    )
  end


  it "check_list_mark() converts list mark token's type" do
    token_list = tokens_as_array("foo - bar\n- baz")
    expect(check_list_mark(token_list).collect {|x| [x.type, x.value]}).to eq(
      [
        ["TEXT", "foo "], ["DASH", '-'], ["TEXT", " bar"], ["NEWLINE", "\n"],
        ["LIST_MARK", "-"], ["TEXT", " baz"], ["EOF", ""]
      ]
    )
  end
end
