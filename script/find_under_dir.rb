#!/usr/bin/env ruby

printf `find ./lib -type file -name "*.rb" | xargs grep -e "#{ARGV[0]}" -n`

# match_star 쓰는 곳에선 parser를 하나만 쓰는지 확인하기
#  find를 쓰자
#  lib 디렉토리 아래 모든 루비 파일에 대해
#  find ./lib -type file -name "*.rb" |\
#  match_star를 포함하는 줄을 검색하고, 그 내용을 출력한다
#  xargs grep -e ".*match_star.*"
#  줄 번호도 함께!
#  -n
