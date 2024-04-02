require 'md2html'
require 'test/unit'

include Test::Unit::Assertions

# 마크다운 포맷 테스트 데이터를 읽어온다
# 읽어온 데이터에 md2html.make_html 메서드를 적용한다
md_file = File.read(File.expand_path('test/data/paragraph/one_para.md'))
puts "----markdown file content----"
puts md_file

# html 포맷 테스트 데이터를 읽어온다
html_file = File.read(File.expand_path('test/data/paragraph/one_para.html'))
puts "----html file content----"
puts html_file
assert_equal(html_file, Md2Html::make_html(md_file))
# md2html.make_html 적용된 결과와 비교한다
