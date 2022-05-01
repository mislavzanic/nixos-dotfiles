class Terraspace::CLI
  class List
    include Concerns::SourceDirs

    def initialize(options={})
      @options = options
      @type_dir = normalized_type
    end

    def run
      source_dirs.each do |path|
        if @type_dir
          puts path if path.include?("/#{@type_dir}/")
        else
          puts path
        end
      end
    end

  private
    def normalized_type
      type = @options[:type]
      if %w[stack module].include?(type)
        type.pluralize
      end
    end
  end
end
