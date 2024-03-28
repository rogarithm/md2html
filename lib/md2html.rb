require_relative 'md2html/tokenizer'
require_relative 'md2html/parser'
require_relative 'md2html/generator'

module Md2Html
  def self.make_html(markdown)
    tokens = Md2Html::Tokenizer::tokenize(markdown)
    ast    = Md2Html::Parser::parse(tokens)
    html   = Md2Html::Generator::generate(ast)
    return html
  end
end
