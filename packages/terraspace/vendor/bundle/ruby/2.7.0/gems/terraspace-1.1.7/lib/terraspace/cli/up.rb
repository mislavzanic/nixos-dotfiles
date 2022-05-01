require 'securerandom'

class Terraspace::CLI
  class Up < Base
    include TfcConcern

    def run
      build
      if @options[:yes] && !@options[:plan] && !tfc?
        plan
        Commander.new("apply", @options.merge(plan: plan_path)).run
      else
        Commander.new("apply", @options).run
      end
    end

  private
    # must build to compute tfc?
    def build
      Terraspace::Builder.new(@options).run
      @options[:build] = false
    end

    def plan
      FileUtils.mkdir_p(File.dirname(plan_path))
      Commander.new("plan", @options.merge(out: plan_path)).run
    end

    def plan_path
      @@random ||= SecureRandom.hex
      "#{Terraspace.tmp_root}/plans/#{@mod.name}-#{@@random}.plan"
    end
  end
end
