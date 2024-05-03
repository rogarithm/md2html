require 'logger'

module Md2Html
  module Util
    class LoggerFactory
      def self.make_logger
        logger = Logger.new('.md2html.log')
        logger.level = Logger::DEBUG
        logger.datetime_format = "%H:%M:%S"
        logger
      end
    end
  end
end
