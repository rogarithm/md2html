require_relative '../lib/md2html/tokenizer'
require_relative '../lib/md2html/parser'
require_relative '../lib/md2html/generator'
Dir.glob('./lib/md2html/generator/*.rb').each do |file|
  require file
end
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

describe Md2Html::Generator do
  def generate(markdown)
    tokens = Md2Html::Tokenizer::tokenize(markdown)
    ast    = Md2Html::Parser::parse(tokens)
    Md2Html::Generator::generate(ast)
  end

  it "generates html from one sentence" do
    tokens = Md2Html::Tokenizer::tokenize("__Foo__ and *text*.")

    parser = Md2Html::Parser::SentenceParser.new
    node = parser.match(tokens)

    generator = Md2Html::Generator::SentenceVisitor.new
    expect(generator.visit(node)).to eq "<strong>Foo</strong> and <em>text</em>."
  end

  it "generates html from paragraph" do
    expect(generate("__Foo__ and *text*.\nAnother para.")).to eq "<p>
  <strong>Foo</strong> and <em>text</em>.<br>Another para.
</p>\n"
  end

  it "generates html from two paragraph" do
    expect(generate("__Foo__ and *text*.\n\nAnother para.")).to eq "<p>
  <strong>Foo</strong> and <em>text</em>.
</p>
<p>
  Another para.
</p>\n"
  end

  it "generates html from 1 list item" do
    expect(generate("- foo\n")).to eq "<ul>
  <li>foo</li>
</ul>\n"
  end

  it "generates html from list" do
    expect(generate("- foo\n- bar\n- baz\n")).to eq "<ul>
  <li>foo</li>
  <li>bar</li>
  <li>baz</li>
</ul>\n"
  end

  it "generates html from problematic list" do
    expect(generate(
      "## HHH\n\nBBB\n\n- C(c): c\n- R(r): r\n\nDDD"
    )).to eq(
      "<h2> HHH</h2>\n<p>\n  BBB\n</p>\n<ul>\n  <li>C(c): c</li>\n  <li>R(r): r</li>\n</ul>\n<p>\n  DDD\n</p>\n"
    )
  end

  it "generates html from level 1 heading" do
    expect(generate("# title\n")).to eq "<h1> title</h1>\n"
  end

  it "generates html from level 2 heading" do
    expect(generate("## title\n")).to eq "<h2> title</h2>\n"
  end

  it "generate html from inline code" do
    expect(generate("hi `foo = bar` there\nlong time no **see**!")).to eq(
      "<p>
  hi <code>foo = bar</code> there<br>long time no <strong>see</strong>!
</p>\n"
    )
  end
end
