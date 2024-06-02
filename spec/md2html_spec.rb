require 'md2html'
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

describe Md2Html do
  it "generates html from paragraph" do
    expect(Md2Html::make_html("__Foo__ and *text*.\nAnother para.")).to eq "<p>
  <strong>Foo</strong> and <em>text</em>.<br>Another para.
</p>\n"
  end

  it "generates html from 1 list item" do
    expect(Md2Html::make_html("- foo\n")).to eq "<ul>
  <li>foo</li>
</ul>\n"
  end

  it "generates html from list" do
    expect(Md2Html::make_html("- foo\n- bar\n- baz\n")).to eq "<ul>
  <li>foo</li>
  <li>bar</li>
  <li>baz</li>
</ul>\n"
  end
end

