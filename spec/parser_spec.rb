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
        x.sentences.collect{|s|
          w = s.words.first
          [
            s.type,
            [w.type, w.value, w.consumed],
            s.consumed
          ]
        }.first,
        x.consumed
      ]}.first).to eq(
        ["LIST", ["LIST_ITEM", ['TEXT', " foo", 1], 3], 4]
      )
    end

    it "can parse list items ends with two newlines and eof" do
      parser = create_parser(:list_items_parser)

      list_nl_nl_eof_token = tokenize("- foo\n\n")
      expect([parser.match(list_nl_nl_eof_token)].collect{|x| [
        x.type,
        x.sentences.collect{|s|
          w = s.words.first
          [
            s.type,
            [w.type, w.value, w.consumed],
            s.consumed
          ]
        },
        x.consumed
      ]}.first).to eq(
        ["LIST", [["LIST_ITEM", ['TEXT', " foo", 1], 3]], 5]
      )
    end

    it "can parse multiple list items ends with eof or newline" do
      parser = create_parser(:list_items_parser)

      list_nl_list_nl_eof_token = tokenize("- foo\n- bar\n")
      expect([parser.match(list_nl_list_nl_eof_token)].collect{|x| [
        x.type,
        x.sentences.collect{|s|
          w = s.words.first
          [
            s.type,
            [w.type, w.value, w.consumed],
            s.consumed
          ]
        },
        x.consumed
      ]}.first).to eq(
        ["LIST", [["LIST_ITEM", ['TEXT', " foo", 1], 3], ["LIST_ITEM", ['TEXT', " bar", 1], 3]], 7]
      )
    end
  end

  context "sentence parser" do
    it "can parse tokens that has inline code" do
      parser = create_parser(:paragraph_parser)
      expected_words = [
        ["TEXT", "hi ", 1],
        ["CODE", 'foo = bar', 1],
        ["TEXT", " there", 1]
      ]

      tokens = tokenize("hi `foo = bar` there\n")
      expect(
        [parser.match(tokens)].collect {|x| [
          x.type,
          x.words.collect{|w| [w.type, w.value, w.consumed]},
          x.consumed
        ]}.first
      ).to eq(
        ["SENTENCE", expected_words, 5]
      )
    end

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
        x.words.collect{|w| [w.type, w.value, w.consumed]},
        x.consumed
      ]}.first

      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 12]
      )

      nl_nl_token = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = [parser.match(nl_nl_token)].collect{|x| [
        x.type,
        x.words.collect{|w| [w.type, w.value, w.consumed]},
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
        x.words.collect{|w| [w.type, w.value, w.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 11]
      )

      token_nl = tokenize("__Foo__ and *text*.\n")
      sentence_node = [parser.match(token_nl)].collect{|x| [
        x.type,
        x.words.collect{|w| [w.type, w.value, w.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ["SENTENCE", expected_words, 12]
      )

      token_nl_nl = tokenize("__Foo__ and *text*.\n\n")
      sentence_node = [parser.match(token_nl_nl)].collect{|x| [
        x.type,
        x.words.collect{|w| [w.type, w.value, w.consumed]},
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
        x.words.collect{|w| [w.type, w.value, w.consumed]},
        x.consumed
      ]}.first
      expect(sentence_node).to eq(
        ['SENTENCE', expected_words, 3]
      )
    end
  end

  context "paragraph parser" do
    it "can parse tokens that has inline code" do
      parser = create_parser(:paragraph_parser)
      ws_s1 = [
        ["TEXT", "hi ", 1],
        ["CODE", 'foo = bar', 1],
        ["TEXT", " there", 1],
        ["NEWLINE", "\\n", 1]
      ]
      ws_s2 = [
        ["TEXT", "long time no ", 1],
        ["BOLD", 'see', 5],
        ["TEXT", "!", 1]
      ]
      tokens = tokenize("hi `foo = bar` there\nlong time no **see**!")
      expect([parser.match(tokens)].collect{|x| [
        x.type,
        x.sentences.collect do |s| [
          s.type,
          s.words.collect{|w| [w.type, w.value, w.consumed]},
          s.consumed
        ]
        end,
        x.consumed
      ]}.first).to eq(
        [
          "PARAGRAPH",
          [["SENTENCE", ws_s1, 4], ["SENTENCE", ws_s2, 8]],
          12
        ]
      )
    end

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
        x.sentences.collect do |s|
          w = s.words.first
          [
          s.type,
          [w.type, w.value, w.consumed],
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
            ["BOLD", "Foo", 5],
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

    node = [parser.match(tokens)].collect {|x|
      s = x.sentences.first
      [
        x.type,
        [
          s.type,
          s.words.collect { |w| [w.type, w.value, w.consumed] },
          s.consumed
        ],
        x.consumed
      ]
    }

    expect(node).to eq(
      [['HEADING', ['SENTENCE', [['TEXT', ' title', 1]], 1], 4]]
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
      node = [parser.match(tokens)].collect do |x|
        s = x.sentences.first
        [
          x.type,
          [
            s.type,
            s.words.collect { |w| [w.type, w.value, w.consumed] },
            s.consumed
          ],
          x.consumed
        ]
      end

      expect(node).to eq(
        [['HEADING', ['SENTENCE', [['TEXT', ' title', 1]], 1], 4]]
      )
    end
  end

  context "heading parser" do
    it "can parse text that has heading" do
      parser = create_parser(:heading_parser)
      tokens = tokenize("# title\n")
      node = [parser.match(tokens)].collect do |x|
        s = x.sentences.first
        [
          x.type,
          [
            s.type,
            s.words.collect { |w| [w.type, w.value, w.consumed] },
            s.consumed
          ],
          x.consumed
        ]
      end

      expect(node).to eq(
        [['HEADING', ['SENTENCE', [['TEXT', ' title', 1]], 1], 4]]
      )
    end

    it "can parse text that has level 2 heading" do
      parser = create_parser(:heading_parser)
      tokens = tokenize("## title\n")
      node = [parser.match(tokens)].collect do |x|
        s = x.sentences.first
        [
          x.type,
          [
            s.type,
            s.words.collect { |w| [w.type, w.value, w.consumed] },
            s.consumed
          ],
          x.consumed
        ]
      end

      expect(node).to eq(
        [['HEADING_LEVEL2', ['SENTENCE', [['TEXT', ' title', 1]], 1], 5]]
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
      body_node = [parser.match(tokens)].collect { |x| [
        x.blocks.collect { |b| [
          b.type,
          b.sentences.collect { |s|
            w = s.words.first
            [
              s.type,
              [w.type, w.value, w.consumed],
              s.consumed
            ]
          }.first,
          b.consumed
        ] },
        x.consumed
      ] }.first

      expect(body_node).to eq(
        [
          [[
            "PARAGRAPH",
            ["SENTENCE_ENDS_EARLY", ["BOLD", "Foo", 5], 7],
            7
          ], [
            "PARAGRAPH",
            ["SENTENCE", ["TEXT", "Another para.", 1], 2],
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

      node = [parse(tokens)].collect do |x| [
        x.type,
        x.blocks.collect do |b|
          [
            b.type,
            b.sentences.collect do |s|
              w = s.words.first
              [
                s.type,
                [w.type, w.value, w.consumed],
                s.consumed
              ]
            end,
            b.consumed
          ]
        end,
        x.consumed
      ] end.first

      expect(node).to eq(
        ['BODY',
          [
            ["LIST",
              [
                ["LIST_ITEM", ["TEXT", " foo", 1], 3],
                ["LIST_ITEM", ["TEXT", " bar", 1], 3],
                ["LIST_ITEM", ["TEXT", " baz", 1], 3]
              ],
              10],
            ["PARAGRAPH",
              [
                ["SENTENCE", ["BOLD", "Foo", 5], 11],
                ["SENTENCE", ["TEXT", "Another para.", 1], 2]
              ],
              13]
          ],
          23
        ]
      )
    end

    it "can parse text that has heading" do
      tokens = tokenize("# title\n")
      node = [parse(tokens)].collect do |x| [
        x.type,
        x.blocks.collect do |b|
          s = b.sentences.first
          [
          b.type,
            [
              s.type,
              s.words.collect {|w| [w.type, w.value, w.consumed]},
              s.consumed
            ],
          b.consumed
        ]
        end.first,
        x.consumed
      ] end.first

      expect(node).to eq(
        [
          'BODY',
          [
            "HEADING",
            ["SENTENCE", [["TEXT", " title", 1]], 1],
            4
          ],
          4
        ]
      )
    end

    it "can parse text that has level 2 heading" do
      tokens = tokenize("## title\n")
      node = [parse(tokens)].collect do |x| [
        x.type,
        x.blocks.collect do |b|
          s = b.sentences.first
          [
            b.type,
            [
              s.type,
              s.words.collect {|w| [w.type, w.value, w.consumed]},
              s.consumed
            ],
            b.consumed
          ]
        end.first,
        x.consumed
      ] end.first

      expect(node).to eq(
        [
          "BODY",
          [
            "HEADING_LEVEL2",
            ["SENTENCE", [["TEXT", " title", 1]], 1],
            5
          ],
          5
        ]
      )
    end

    it "can parse text that has heading and another" do
      tokens = tokenize("# title\n\nand another blocks")

      node = [parse(tokens)].collect do |x|
        [
          x.type,
          x.blocks.collect do |b|
            s = b.sentences.first
            [
              b.type,
              [
                s.type,
                s.words.collect {|w| [w.type, w.value, w.consumed]},
                s.consumed
              ],
              b.consumed
            ]
          end,
          x.consumed
        ]
      end.first

      expect(node).to eq(
        [
          "BODY",
          [
            [
              "HEADING",
              ["SENTENCE", [["TEXT", " title", 1]], 1],
              4
            ],
            [
              "PARAGRAPH",
              ["SENTENCE", [["TEXT", "and another blocks", 1]], 2],
              2
            ]
          ],
          6
        ]
      )
    end

    it "can parse text that has level 2 heading and another" do
      tokens = tokenize("## title\n\nand another blocks")

      node = [parse(tokens)].collect do |x|
        [
          x.type,
          x.blocks.collect do |b|
            s = b.sentences.first
            [
              b.type,
              [
                s.type,
                s.words.collect {|w| [w.type, w.value, w.consumed]},
                s.consumed
              ],
              b.consumed
            ]
          end,
          x.consumed
        ]
      end.first

      expect(node).to eq(
        [
          "BODY",
          [
            [
              "HEADING_LEVEL2",
              ["SENTENCE", [["TEXT", " title", 1]], 1],
              5
            ],
            [
              "PARAGRAPH",
              ["SENTENCE", [["TEXT", "and another blocks", 1]], 2],
              2
            ]
          ],
          7
        ]
      )
    end
  end
end
