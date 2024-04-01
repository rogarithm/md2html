require 'md2html'
require 'pry'

describe Md2Html do
  it "generates html from paragraph" do
    expect(Md2Html::make_html("__Foo__ and *text*.\n\nAnother para.")).to eq "<p><strong>Foo</strong> and <em>text</em>.</p><p>Another para.</p>"
  end

  it "generates html from 1 list item" do
    expect(Md2Html::make_html("- foo\n")).to eq "<ul><li>foo</li></ul>"
  end

  it "generates html from list" do
    expect(Md2Html::make_html("- foo\n- bar\n- baz\n")).to eq "<ul><li>foo</li><li>bar</li><li>baz</li></ul>"
  end
end

