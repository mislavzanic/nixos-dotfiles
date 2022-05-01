require "singleton"

module DslEvaluator
  class App
    extend Memoist
    include Singleton

    attr_reader :config
    def initialize
      @config = defaults
    end

    def defaults
      config = ActiveSupport::OrderedOptions.new

      config.logger = default_logger
      config.logger.formatter = Logger::Formatter.new
      config.logger.level = ENV['DSL_EVALUATOR_LOG_LEVEL'] || :info

      config.on_exception = :raise

      config.root = Dir.pwd

      config.backtrace = ActiveSupport::OrderedOptions.new
      config.backtrace.reject_pattern = nil # dont use .reject. Seems its used internally by ActiveSupport::OrderedOptions
      config.backtrace.select_pattern = nil

      config
    end

    def default_logger
      Logger.new(ENV['DSL_EVALUATOR_LOG_PATH'] || $stderr)
    end
    memoize :default_logger

    def configure
      yield(@config)
    end
  end
end
