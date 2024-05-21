require_relative '../lib/md2html/parser/parser_factory'
require 'pry'

describe Md2Html::Parser::MatchesStar do
  let(:ms) { Class.new { extend Md2Html::Parser::MatchesStar } }
  let(:mf) { Class.new { extend Md2Html::Parser::MatchesFirst } }
  let(:mp) { Class.new { extend Md2Html::Parser::MatchesPlus } }

  before(:each) do
    @sentence_element_parser = Md2Html::Parser::ParserFactory.build(:sentence_element_parser)
    @inline_parser = Md2Html::Parser::ParserFactory.build(:inline_parser)
    @text_parser = Md2Html::Parser::ParserFactory.build(:text_parser)
  end

  it "matchesStar matches 0 or more" do
    zero = Md2Html::Tokenizer::tokenize("")
    nodes, consumed = ms.match_star(zero, with: @sentence_element_parser)
    expect(consumed).to eq(0)

    one = Md2Html::Tokenizer::tokenize("matches 0 or more\n")
    nodes, consumed = ms.match_star(one, with: @sentence_element_parser)
    expect(consumed).to eq(1)

    more = Md2Html::Tokenizer::tokenize("- matches 0 or more\n")
    nodes, consumed = ms.match_star(more, with: @sentence_element_parser)
    expect(consumed).to eq(2)
  end

  it "matchesFirst matches only 1" do
    zero = Md2Html::Tokenizer::tokenize("\n")
    node = mf.match_first(zero, @inline_parser, @text_parser)
    expect(node).to eq(Md2Html::Parser::Node.null)

    one = Md2Html::Tokenizer::tokenize("ttt\n")
    node = mf.match_first(one, @inline_parser, @text_parser)
    expect(node.consumed).to eq(1)

    two = Md2Html::Tokenizer::tokenize("- ttt\n")
    node = mf.match_first(two, @inline_parser, @text_parser)
    expect(node.consumed).to eq(1)
  end

  it "matchesPlus matches 1 or more" do
    zero = Md2Html::Tokenizer::tokenize("")
    nodes, consumed  = mp.match_plus(zero, with: @sentence_element_parser)
    expect(nodes).to eq([])

    one = Md2Html::Tokenizer::tokenize("ttt")
    nodes, consumed  = mp.match_plus(one, with: @sentence_element_parser)
    expect(nodes.first.value).to eq("ttt")
    expect(consumed).to eq(1)
  end
end
