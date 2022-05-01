require 'thor'

class Terraspace::CLI::New
  class Sequence < Thor::Group
    include Thor::Actions
    include Terraspace::Util::Logging
    include Helpers

    def self.base_options
      [
        [:examples, type: :boolean, default: false, desc: "Also generate examples"],
        [:force, aliases: %w[y], type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        [:lang, default: "hcl", desc: "Language to use: HCL/ERB or Ruby DSL"],
        [:plugin, aliases: %w[p], default: "aws", desc: "Cloud Plugin. Supports: aws, google"],
        [:test, type: :boolean, desc: "Whether or not to generate tests"],
        [:plugin_gem, desc: "Use if provider gem name doesnt follow terraspace_plugin_XXX naming convention. Must specify both --plugin and --plugin-name option"],
      ]
    end

    def self.component_options
      [
        [:project_name, desc: "Only used internally", hide: true],
      ]
    end

    base_options.each { |args| class_option(*args) }

    argument :name

  private
    def component_args(component_name, project_name=nil)
      args = [
        component_name,
        "--project-name", project_name,
      ]

      args += ["--lang", @options[:lang]] if @options[:lang]
      args += ["--plugin", @options[:plugin]] if @options[:plugin]
      args += ["--plugin-gem", @options[:plugin_gem]] if @options[:plugin_gem]
      args += @options[:test] ? ["--test"] : ["--no-test"] # since test may be true by default
      args += ["--examples"] if @options[:examples]
      args += ["--force"] if @options[:force]
      args
    end

    # friendly method
    def plugin_template_source(template, type)
      source = Source::Plugin.new(self, @options)
      source.set_source_paths(template, type)
    end
  end
end
