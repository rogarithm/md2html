쓸 markdown에 대한 bnf 정의하기

테스트를 좀 더 만들기
모듈 구조 어떻게 하는 게 좋을까?
 디렉토리 구조에 맞게 파서 관련 클래스의 namespace 바꿔주기
 파서를 별도의 라이브러리로 만들고 autoblog에선 import만 해주도록 하기
디렉토리 이름을 복수 형태로 하는 게 일반적인가?

converter
 tokenizer
  scanners
  tokens
 parser
  nodes
  parsers
   converns
 generator
  visitors
 
parser 동작 방식 분석하기
tokenizer
 scanner

String -> Array -> TokenList -> 

String -> Array
 String의 일부로부터 token이 만들어지면 String은 그만큼 줄어드나?
 줄어든다. 근데 왜 줄어들까?
 -> 메서드를 재귀적으로 호출하기 때문이다. 그래서 다음번 호출마다 그때 스캔한 토큰 길이만큼 인덱스가 밀린다.
 Scanner가 두 개인데, 두 Scanner 모두에서 스캔하면 결과는 두 개로 나오나?
 -> SimpleScanner, TextScanner의 순서대로 스캔한다. 만약 SimpleScanner에서 스캔한 결과가 Token.null이 아니라면 그대로 그 결과를 반환하고, TextScanner는 스캔하지 않는다. 하지만 SimpleScanner에서 스캔한 결과가 Token.null이라면 TextScanner가 스캔을 시작한다.

Parser에서 token을 모아서 유의미한 단위로 만든다
 이외 마크다운 양식은 어떻게 token으로 변환해야 하나?

SimpleScanner, TextScanner를 내 요구 사항에 맞춰 바꾸기


Parser
여러 Text가 합해진 패턴을 Sentence로 볼 수는 없나? SentencesAndNewline과 SentencesAndEOF를 Paragraph로 본다고 했을 떄, Sentence를 다른 이름으로 보는 게 더 괜찮아보인다.
parser를 하나의 문법 규칙에 해당하는 작은 객체로 정의한다. 각 parser 객체는 다른 parser 객체를 호출하거나, 자기 자신을 호출할 수 있다
node는 왜 parser 패키지에 같이 있을까?

parser 테스트 환경 만들기
 --xxx 옵션으로 테스트할 파일 구분할 수 있게 만들기
 ex. rake test --token, rake test --parser

parser.match로 얻은 결과를 모아서 abstract syntax tree를 만든다. 그래서 이 결과를 node라고 부른다.
