class DslEvaluator::Printer
  module Concern
    # So other libraries can use this method
    # The `print_code` method understands "polymorphic" arguments.
    # See README.md
    def print_code(*args)
      if args.size == 2 # print_code(path, line_number)
        path, line_number = args
      else # print_code(caller_line)
        # IE: .ufo/config/web/dev.rb:10:in `block in evaluate_file'
        # User passed in a "standard" ruby backtrace call line
        #   windows: "C:/Ruby31-x64/lib/ruby/gems/3.1.0/gems/terraspace-1.1.1/lib/terraspace/builder.rb:34:in `build'"
        #   linux: "/home/ec2-user/.rvm/gems/ruby-3.0.3/gems/terraspace-1.1.1/lib/terraspace/compiler/dsl/syntax/mod.rb:4:in `<module:Mod>'"
        caller_line = args[0]
        parts = caller_line.split(':')
        is_windows = caller_line.match(/^[a-zA-Z]:/)  # windows vs linux
        calling_file = is_windows ? parts[1] : parts[0]
        line_number  = is_windows ? parts[2] : parts[1]
        path = calling_file
      end

      check_line_number!(line_number)
      line_number = line_number.to_i

      logger.info "Here's the original caller line from:"
      logger.info pretty_path(path).color(:green)

      contents = IO.read(path)
      content_lines = contents.split("\n")
      context = 5 # lines of context
      top, bottom = [line_number-context-1, 0].max, line_number+context-1
      lpad = content_lines.size.to_s.size
      content_lines[top..bottom].each_with_index do |line_content, index|
        current_line = top+index+1
        if current_line == line_number
          printf("%#{lpad}d %s\n".color(:red), current_line, line_content)
        else
          printf("%#{lpad}d %s\n", current_line, line_content)
        end
      end

      logger.info "Rerun with FULL_BACKTRACE=1 to see full backtrace" unless ENV['FULL_BACKTRACE']
    end

    def check_line_number!(line_number)
      return line_number unless line_number.is_a?(String)
      integer = line_number.to_i
      if integer == 0
        logger.error "ERROR: Think you accidentally passed in a String for the line_number: #{line_number}".color(:red)
        puts caller
        exit 1
      end
    end

    def pretty_path(path)
      path.sub("#{Dir.pwd}/",'').sub(/^\.\//,'')
    end

    # Replace HOME with ~ - different from the main pretty_path
    def pretty_home(path)
      path.sub(ENV['HOME'], '~')
    end
  end
end

