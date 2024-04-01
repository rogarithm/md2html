#!/usr/bin/env ruby

path = ARGV[0]
module_name = ARGV[1] ||= 'Md2Html'

#lib 디렉토리 아래 루비 파일을 찾는다
file_list = `find ./lib/md2html/#{path} -name '*.rb'`.split("\n")

#ruby_file = 'lib/generator/visitors/bold_visitor.rb'
#각 루비 파일마다
file_list.each do |ruby_file|
  #class나 module로 시작하는 줄 번호를 구한다
  #sed 실행 결과에서 줄 번호를 가진 줄만 남기고 지운다
  module_or_class_at = `cat #{ruby_file} |\
  grep -E '^[module|class]' -n |\
  head -n1 |\
  cut -d: -f1`.to_i - 1 #class/module로 시작하는 줄 위에 문자열을 추가하기 위해 줄 번호에서 1을 뺀다

  #먼저 빈 줄을 넣고,
  if module_or_class_at == 0
    module_or_class_at = 1
  #  `sed -i '#{module_or_class_at}s/^/\\n\\n/' #{ruby_file}`
  #else
  end
  `sed -i '#{module_or_class_at}s/^/\\n/' #{ruby_file}`
  
  #그 아랫줄에
  module_or_class_at = module_or_class_at + 1
  #'module Md2Html'을 덧붙인다
  `sed -i '#{module_or_class_at}i\\
  module #{module_name}' #{ruby_file}`
  #마지막 줄에 module 끝을 나타내는 end를 적는다
  `echo 'end' >> #{ruby_file}`
end
