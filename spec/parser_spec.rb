require_relative '../lib/md2html/parser'
require_relative '../lib/md2html/tokenizer'
Dir.glob('./lib/md2html/parser/*.rb').each do |file|
  require file
end
require 'pry'
require_relative './helpers/spec_helper'

RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
  config.example_status_persistence_file_path = 'spec/pass_fail_history'
end

def tokenize string
  Md2Html::Tokenizer::tokenize string
end

def create_parser name
  Md2Html::Parser::ParserFactory.build(name)
end

def create_node attrs
  Md2Html::Parser::Node.new attrs
end

def create_sentence_node attrs
  Md2Html::Parser::SentenceNode.new attrs
end

def create_paragraph_node attrs
  Md2Html::Parser::ParagraphNode.new attrs
end

def create_list_node attrs
  Md2Html::Parser::ListNode.new attrs
end

def create_body_node attrs
  Md2Html::Parser::BodyNode.new attrs
end

def parse tokens
  Md2Html::Parser::parse tokens
end

describe Md2Html::Parser, "parser" do

  context "inline parser" do
    it "can parse tokens that has bold tag" do
      parser = create_parser(:inline_parser)

      bold_token = tokenize("**foo**")
      expect(
         [parser.match(bold_token)].collect{|x| [x.type, x.value, x.consumed]}
      ).to eq(
        [['BOLD', bold_token.third.value, 5]]
      )
    end

    it "can parse tokens that has emphasis tag" do
      parser = create_parser(:inline_parser)

      emphasis_token = tokenize("*foo*")
      expect(
        [parser.match(emphasis_token)].collect {|x| [x.type, x.value, x.consumed]}
      ).to eq(
        [['EMPHASIS', emphasis_token.second.value, 3]]
      )
    end

    it "can parse tokens that has dash tag" do
      parser = create_parser(:inline_parser)

      dash_token = tokenize("-")
      expect(
        [parser.match(dash_token)].collect {|x| [x.type, x.value, x.consumed]}
      ).to eq(
        [['DASH', dash_token.first.value, 1]]
      )
    end
  end

  context "list items parser" do
    it "can parse list item ends with eof" do
      parser = create_parser(:list_items_parser)

      list_nl_eof_token = tokenize("- foo\n")
      expect([parser.match(list_nl_eof_token)].collect{|x| [
        x.type,
        x.sentences.collect{|s| [s.type, s.value, s.consumed]}.first,
        x.consumed
      ]}.first).to eq(
        ["LIST", ["LIST_ITEM", " foo", 3], 4]
      )
    end

    it "can parse list items ends with two newlines and eof" do
      parser = create_parser(:list_items_parser)

      list_nl_nl_eof_token = tokenize("- foo\n\n")
      expect([parser.match(list_nl_nl_eof_token)].collect{|x| [
        x.type,
        x.sentences.collect{|s| [s.type, s.value, s.consumed]}.first,
        x.consumed
      ]}.first).to eq(
        ["LIST", ["LIST_ITEM", " foo", 3], 5]
      )
    end

    it "can parse multiple list items ends with eof or newline" do
      parser = create_parser(:list_items_parser)

      list_nl_list_nl_eof_token = tokenize("- foo\n- bar\n")
      expect([parser.match(list_nl_list_nl_eof_token)].collect{|x| [
        x.type,
        x.sentences.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first).to eq(
        ["LIST", [["LIST_ITEM", " foo", 3], ["LIST_ITEM", " bar", 3]], 7]
      )
    end
  end

  context "sentence parser" do
    it "can parse one sentence without eof in mind" do
      parser = create_parser(:sentence_parser)
      expected_words = [
        ['BOLD', 'Foo', 5],
        ['TEXT', ' and ', 1],
        ['EMPHASIS', 'text', 3],
        ['TEXT', '.', 1]
      ]

      nl_token = tokenize("__Foo__ and *text*.\n")
      sentence_node = [parser.match(nl_token)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first

      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 12]
      )

      nl_nl_token = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = [parser.match(nl_nl_token)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 13]
      )
    end

    it "can parse one sentence with eof in mind" do
      parser = create_parser(:sentence_parser)
      expected_words = [
        ['BOLD', 'Foo', 5],
        ['TEXT', ' and ', 1],
        ['EMPHASIS', 'text', 3],
        ['TEXT', '.', 1]
      ]

      token_no_nl = tokenize("__Foo__ and *text*.")
      sentence_node = [parser.match(token_no_nl)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 11]
      )

      token_nl = tokenize("__Foo__ and *text*.\n")
      sentence_node = [parser.match(token_nl)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 12]
      )

      token_nl_nl = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = [parser.match(token_nl_nl)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 13]
      )
    end

    it "can parse tokens that has escaped special char" do
      parser = create_parser(:sentence_parser)
      expected_words = [
        ['TEXT', '-',  1],
        ['TEXT', ' blah blah', 1]
      ]

      tokens = tokenize("\\- blah blah")
      sentence_node = [parser.match(tokens)].collect{|x| [
        x.type,
        x.words.collect{|s| [s.type, s.value, s.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ['SENTENCE', expected_words, 3]
      )
    end
  end

  context "paragraph parser" do
    it "can parse tokens that has escaped special char" do
      parser = create_parser(:block_parser)

      tokens = tokenize("\\- blah blah")
      expect([parser.match(tokens)].collect{|x| [
        x.type,
        x.sentences.collect do |s| [
            s.type,
            s.words.collect{|w| [w.type, w.value, w.consumed]},
            s.consumed
          ]
        end.first,
        x.consumed
      ]}.first).to eq(
        [
          "PARAGRAPH",
          [
            "SENTENCE",
            [["TEXT", "-", 1], ["TEXT", " blah blah", 1]],
            3
          ],
          3
        ]
      )
    end

    it "can parse paragraph" do
      parser = create_parser(:paragraph_parser)

      tokens = tokenize("__Foo__ and *text*.\n**Foo** and *text*.")
      paragraph_node = [parser.match(tokens)].collect{|x| [
        x.type,
        x.sentences.collect do |s| [
          s.type,
          s.words.collect{|w| [w.type, w.value, w.consumed]},
          s.consumed
        ]
        end,
        x.consumed
      ]}.first

      words_1 = [
        ['BOLD', 'Foo', 5], ['TEXT', ' and ', 1], ['EMPHASIS', 'text', 3],
        ['TEXT', '.', 1], ['NEWLINE', '\n', 1]
      ]
      words_2 = [
        ['BOLD', 'Foo', 5], ['TEXT', ' and ', 1], ['EMPHASIS', 'text', 3],
        ['TEXT', '.', 1]
      ]

      expect(paragraph_node).to eq(
        [
          "PARAGRAPH",
          [
            ["SENTENCE", words_1, 11],
            ["SENTENCE", words_2, 11]
          ],
          22
        ]
      )
    end

    it "can detect paragraph that ends early" do
      parser = create_parser(:paragraph_parser)

      tokens = tokenize("**Foo**\n\nAnother para.")
      early_ends_1_sentence_para = [parser.match(tokens)].collect{|x| [
        x.type,
        x.sentences.collect do |s| [
          s.type,
          s.words.collect{|w| [w.type, w.value, w.consumed]},
          s.consumed
        ]
        end.first,
        x.consumed
      ]}.first

      expect(early_ends_1_sentence_para).to eq(
        [
          "PARAGRAPH",
          [
            "SENTENCE_ENDS_EARLY",
            [["BOLD", "Foo", 5]],
            7
          ],
          7
        ]
      )

      tokens_b = tokenize("**Foo**\nBar\n\nAnother para.")
      early_ends_2_sentences_para = [parser.match(tokens_b)].collect{|x| [
        x.type,
        x.sentences.collect do |s| [
          s.type,
          s.words.collect{|w| [w.type, w.value, w.consumed]},
          s.consumed
        ]
        end,
        x.consumed
      ]}.first

      expect(early_ends_2_sentences_para).to eq(
        [
          "PARAGRAPH",
          [
            ["SENTENCE", [["BOLD", "Foo", 5], ["NEWLINE", "\\n", 1]], 6],
            ["SENTENCE_ENDS_EARLY", [["TEXT", "Bar", 1]], 3]
          ],
          9
        ]
      )
    end
  end

  it "heading parser parse text that has hash character" do
    parser = create_parser(:heading_parser)

    tokens = tokenize("# title\n")
    node = [parser.match(tokens)].collect {|w| [w.type, w.value, w.consumed]}

    expect(node).to eq(
      [['HEADING', ' title', 4]]
    )
  end

  context "block parser" do
    it "can parse text that has dash character" do
      parser = create_parser(:block_parser)

      tokens = tokenize("- foo")
      paragraph_node_consumed = [parser.match(tokens)].collect{|x| [x.consumed]}.first

      expect(paragraph_node_consumed).to eq [3]
    end

    it "can parse text that has hash character" do
      parser = create_parser(:block_parser)

      tokens = tokenize("# title\n")
      node = [parser.match(tokens)].collect { |hd| [hd.type, hd.value, hd.consumed] }

      expect(node).to eq(
        [['HEADING', ' title', 4]]
      )
    end
  end

  context "heading parser" do
    it "can parse text that has heading" do
      parser = create_parser(:heading_parser)
      tokens = tokenize("# title\n")
      node = [parser.match(tokens)].collect { |hd| [hd.type, hd.value, hd.consumed] }

      expect(node).to eq(
        [['HEADING', ' title',4]]
      )
    end

    it "can parse text that has level 2 heading" do
      parser = create_parser(:heading_parser)
      tokens = tokenize("## title\n")
      node = [parser.match(tokens)].collect { |hd| [hd.type, hd.value, hd.consumed] }

      expect(node).to eq(
        [['HEADING_LEVEL2', ' title', 5]]
      )
    end
  end

  context "body parser" do
    it "can parse text that has dash character" do
      parser = create_parser(:body_parser)

      tokens = tokenize("- foo")
      paragraph_node = [parser.match(tokens)].collect{|x| [x.consumed]}.first

      expect(paragraph_node).to eq [3]
    end

    it "can parse two paragraphs" do
      parser = create_parser(:body_parser)

      tokens = tokenize("**Foo**\n\nAnother para.")
      body_node = [parser.match(tokens)].collect { |b| [
        b.blocks.collect { |p| [
          p.type,
          p.sentences.collect { |s| [
            s.type,
            s.words.collect { |w| [w.type, w.value, w.consumed] },
            s.consumed
          ] }.first,
          p.consumed
        ] },
        b.consumed
      ] }.first

      expect(body_node).to eq(
        [
          [[
            "PARAGRAPH",
            ["SENTENCE_ENDS_EARLY", [["BOLD", "Foo", 5]], 7],
            7
          ], [
            "PARAGRAPH",
            ["SENTENCE", [["TEXT", "Another para.", 1]], 2],
            2
          ]],
          9
        ]
      )
    end
  end

  context "with parser chain" do
    it "can parse text that has dash character" do
      tokens = tokenize("- foo")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 3
    end

    it "can parse 1 list item and newline" do
      tokens = tokenize("- foo\n")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 4
    end

    it "can parse list items of the same level" do
      tokens = tokenize("- foo\n- bar\n- baz\n")
      nodes = parse(tokens)
      expect(nodes.consumed).to eq 10 #(dash text newline) * 3 + eof
    end

    it "can parse plain paragraph and list items of the same level" do
      tokens = tokenize("- foo\n- bar\n- baz\n\n__Foo__ and *text*.\nAnother para.")

      # TODO
      #  list_items_parser가 sentence_parser로 sentence 필드를
      #  sentence_node로 바꾸게 한 뒤에 다시 시도해보기
      # xs = [parse(tokens)].collect do |bd| [
      #   bd.blocks.collect do |block|
      #     [
      #       block.type,
      #       block.sentences.collect do |sentence|
      #         [sentence.type, sentence.words, sentence.consumed]
      #       end,
      #       block.consumed
      #     ]
      #   end,
      #   bd.consumed
      # ] end.first
      # p xs

      nodes = parse(tokens)

      expect(nodes).to eq_body_node(
        create_body_node(
          blocks:[
            create_list_node(
              sentences: [
                create_node(type: 'LIST_ITEM', value: ' foo', consumed: 3),
                create_node(type: 'LIST_ITEM', value: ' bar', consumed: 3),
                create_node(type: 'LIST_ITEM', value: ' baz', consumed: 3),
              ],
              consumed: 10
            ),
            create_paragraph_node(
              sentences: [
                create_sentence_node(words: [
                  create_node(type: 'BOLD', value: 'Foo', consumed: 5),
                  create_node(type: 'TEXT', value: ' and ', consumed: 1),
                  create_node(type: 'EMPHASIS', value: 'text', consumed: 3),
                  create_node(type: 'TEXT', value: '.', consumed: 1),
                  create_node(type: 'NEWLINE', value: '\n', consumed: 1)
                ], consumed: 12),
                create_sentence_node(words: [
                  create_node(type: 'TEXT', value: 'Another para.', consumed: 1),
                ], consumed: 1),
              ],
              consumed: 13
            )
          ],
          consumed: 23
        )
      )
    end

    it "can parse text that has heading" do
      tokens = tokenize("# title\n")
      node = [parse(tokens)].collect do |body| [
        body.blocks.collect { |n| [n.type, n.value, n.consumed] }.first,
        body.consumed
      ] end.first

      expect(node).to eq([["HEADING", " title", 4], 4])
    end

    it "can parse text that has level 2 heading" do
      tokens = tokenize("## title\n")
      node = [parse(tokens)].collect do |body| [
        body.blocks.collect { |n| [n.type, n.value, n.consumed] }.first,
        body.consumed
      ] end.first

      expect(node).to eq([["HEADING_LEVEL2", " title", 5], 5])
    end

    it "can parse text that has heading and another" do
      tokens = tokenize("# title\n\nand another blocks")

      # TODO
      #  duck typing을 간단하게 하려면 heading_parser가 node 말고 어떤 type의 node를 반환해야할까?
      # xs = [parse(tokens)].collect do |body|
      #   [
      #     body.blocks,
      #     body.consumed
      #   ]
      # end
      # p xs

      node = parse(tokens)

      expect(node).to eq_body_node(
        create_body_node(
          blocks: [
            create_node(type: 'HEADING', value: ' title', consumed: 4),
            create_paragraph_node(
              sentences: [
                create_sentence_node(words: [
                  create_node(type: 'TEXT', value: 'and another blocks', consumed: 1),
                ], consumed: 2)
              ],
              consumed: 2
            )
          ],
          consumed: 6
        )
      )
    end

    it "can parse text that has level 2 heading and another" do
      tokens = tokenize("## title\n\nand another blocks")
      node = parse(tokens)

      expect(node).to eq_body_node(
        create_body_node(
          blocks: [
            create_node(type: 'HEADING_LEVEL2', value: ' title', consumed: 5),
            create_paragraph_node(
              sentences: [
                create_sentence_node(words: [
                  create_node(type: 'TEXT', value: 'and another blocks', consumed: 1),
                ], consumed: 2)
              ],
              consumed: 2
            )
          ],
          consumed: 7
        )
      )
    end
  end
end
