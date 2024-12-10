require_relative '../lib/md2html'
require 'test/unit'

include Test::Unit::Assertions

paths = [
  'bold/bold', 'paragraph/one_para', 'paragraph/one_para_with_br', 'paragraph/two_para',
  'paragraph/inline_code', 'list/list', 'escape/escape', 'heading/level_1', 'heading/level_2',
  'list/list_2', 'list/list_3'
]
paths.each do |path|
  # 마크다운 포맷 테스트 데이터를 읽어온다
  # 읽어온 데이터에 md2html.make_html 메서드를 적용한다
  md_file = File.read(File.expand_path("test/data/#{path}.md"))

  # html 포맷 테스트 데이터를 읽어온다
  html_file = File.read(File.expand_path("test/data/#{path}.html"))

  # md2html.make_html 적용된 결과와 비교한다
  assert_equal(html_file, Md2Html::make_html(md_file))
end
