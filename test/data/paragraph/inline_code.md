다음 명령은 인덱스에 포함되지 않았고, 추적 상태이며, 변경 사항이 있는 파일만 뽑아내서 해당 파일의 변경 사항만 가져온다.
`git status --short | grep -E '^ M' | sed -e 's/^...//' | xargs git diff`
