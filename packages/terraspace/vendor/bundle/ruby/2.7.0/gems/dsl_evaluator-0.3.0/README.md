# DslEvaluator

Small module to help with DSL evaluation. Notably, it produces a human-friendly backtrace error showing the original user-provided source code if there's a syntax error.

## Usage

Example usage:

```ruby
DslEvaluator.configure do |config|
  config.backtrace.reject_pattern = "/lib/lono"
  config.logger = Lono.logger
  config.on_exception = :exit
  config.root = Lono.root
end

class Dsl
  include DslEvaluator
  def build
    path = "/path/to/user/provided/dsl/file.rb"
    evaluate_file(path) # from DslEvaluator module
  end
end
```

## Print Code Helper

For other libraries where printing the code and context lines around the code is useful, you can use `DslEvaluator.print_code`.

The `print_code` method understands "polymorphic" arguments.

1. If the caller line info is part of a standard ruby backtrace line. Example of this is in ufo [helpers/ecr.rb](https://github.com/boltops-tools/ufo/blob/master/lib/ufo/task_definition/helpers/ecr.rb)

```ruby
call_line = ufo_config_call_line
DslEvaluator.print_code(call_line)
```

2. If the caller line info is custom.  Example of this is in ufo [erb/yaml.rb](https://github.com/boltops-tools/ufo/blob/9247b77c6ad2a3a6307155a2a130308a24668333/lib/ufo/task_definition/erb/yaml.rb#L16)

```ruby
path = "replace with path to file"
line_number = "replace with line number. usually can get the exception.message"
DslEvaluator.print_code(path, line_number)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dsl_evaluator'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dsl_evaluator

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tongueroo/dsl_evaluator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
