require_relative 'parser/parser_factory'
require_relative 'util/logger_factory'

# Transforms a list of tokens into an Abstract Syntax Tree.

module Md2Html
  module Parser
    def self.parse(tokens)
      @logger ||= Md2Html::Util::LoggerFactory.make_logger()
      make_log_msg(@logger, tokens)

      body = body_parser.match(tokens)

      raise "Syntax error: tokens.count is not equal to body.consumed" unless tokens.count == body.consumed
      body
    end

    private

    def self.body_parser
      @body_parser ||= ParserFactory.build(:body_parser)
    end

    def self.make_log_msg(logger, tokens)
      path = "#{File.dirname(__FILE__).split("/")[-1]}/#{File.basename(__FILE__)}"
      logger.debug("#{path} tokens.count: #{tokens.count}")
      all_tokens_info = ""
      tokens.each {|t| all_tokens_info << "#{t.value}(#{t.type})"}
      logger.debug("#{path} all_tokens_info: #{all_tokens_info}")
    end
  end
end
