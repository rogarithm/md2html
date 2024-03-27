require_relative '../lib/md2html/parser/parser_factory'
require 'pry'

describe MatchesStar do
  let(:ms) { Class.new { extend MatchesStar } }
  let(:mf) { Class.new { extend MatchesFirst } }
  let(:mp) { Class.new { extend MatchesPlus } }

  before(:each) do
    @sentence_parser = ParserFactory.build(:sentence_parser)
    @dash_parser = ParserFactory.build(:dash_parser)
    @text_parser = ParserFactory.build(:text_parser)
  end

  it "matchesStar matches 0 or more" do
    zero = Md2Html::Tokenizer::tokenize("")
    nodes, consumed = ms.match_star(zero, with: @sentence_parser)
    expect(consumed).to eq(0)

    one = Md2Html::Tokenizer::tokenize("matches 0 or more\n")
    nodes, consumed = ms.match_star(one, with: @sentence_parser)
    expect(consumed).to eq(1)

    more = Md2Html::Tokenizer::tokenize("- matches 0 or more\n")
    nodes, consumed = ms.match_star(more, with: @sentence_parser)
    expect(consumed).to eq(2)
  end

  it "matchesFirst matches only 1" do
    zero = Md2Html::Tokenizer::tokenize("\n")
    node = mf.match_first(zero, @dash_parser, @text_parser)
    expect(node).to eq(Node.null)

    one = Md2Html::Tokenizer::tokenize("ttt\n")
    node = mf.match_first(one, @dash_parser, @text_parser)
    expect(node.consumed).to eq(1)

    two = Md2Html::Tokenizer::tokenize("- ttt\n")
    node = mf.match_first(two, @dash_parser, @text_parser)
    expect(node.consumed).to eq(1)
  end

  it "matchesPlus matches 1 or more" do
    zero = Md2Html::Tokenizer::tokenize("")
    nodes, consumed  = mp.match_plus(zero, with: @sentence_parser)
    expect(nodes).to eq([])

    one = Md2Html::Tokenizer::tokenize("ttt")
    nodes, consumed  = mp.match_plus(one, with: @sentence_parser)
    expect(nodes.first.value).to eq("ttt")
    expect(consumed).to eq(1)
  end
end
