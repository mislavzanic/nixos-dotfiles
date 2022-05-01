require 'active_support'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'dsl_evaluator/version'
require 'memoist'
require 'rainbow/ext/string'

require "dsl_evaluator/autoloader"
DslEvaluator::Autoloader.setup

module DslEvaluator
  extend Memoist
  include Printer::Concern

  class Error < StandardError; end

  def evaluate_file(path)
    return unless path && File.file?(path)
    instance_eval(IO.read(path), path)
  rescue Exception => e
    Printer.new(e).print
    case config.on_exception
    when :rescue
      # do nothing
    when :exit
      exit 1
    else # :raise
      raise
    end
  end

  mattr_accessor :backtrace_reject

  def logger
    config.logger
  end

  def configure(&block)
    App.instance.configure(&block)
  end

  def config
    App.instance.config
  end
  memoize :config

  extend self
end
