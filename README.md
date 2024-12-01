### 소개
- 마크다운 형식 파일을 html 형식 파일로 바꿔주는 파서
- tokenizer, parser, generator의 세 레이어로 구분
- tokenizer: 마크다운 형식 파일의 내용을 입력받아 token으로 쪼개는 역할
- parser: token을 입력받아 의미있는 형태가 되도록 여러 개의 token을 합쳐 node로 만드는 역할
- generator: node를 입력받아 알맞은 generator에 요청해 html 문자열로 바꾸는 역할

### 지원하는 태그 목록
- heading level 1, 2: `#x, ##y -> <h1>x</h1>, <h2>y</h2>`
- 중첩되지 않은 순서 없는 리스트
- bold: `__Foo__ 또는 **Foo** -> <strong>Foo<strong>`
- italic: `_Foo_ 또는 *Foo* -> <em>Foo<em>`
- 인라인 코드: '\`' 문자로 감싼 문자열을 `<code>` 태그 처리
- 특수문자: "\\" 문자로 시작할 경우 escape 처리
- `<br>` 태그: 한 줄 띄었을 때 `<br>` 태그 추가
- 단락 태그: 두 줄 띄었을 때 `<p>` 태그로 구분
