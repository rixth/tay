require 'thor'

module Tay
  ##
  # Runs tay's command line interface
  class CLI < ::Thor
    DEFAULT_TAYFILE = 'Tayfile'

    include ::Thor::Actions

    desc 'validate', 'Validate the current extension'
    method_option 'tayfile', :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    method_option :built_directory, :type => :string, :default => 'build',
      :aliases => '-b', :banner => 'The directory containing the built extension'
    def validate
      spec = get_specification
      build_dir = File.expand_path(options[:built_directory], File.dirname(tayfile_path))

      validator = SpecificationValidator.new(spec, build_dir)
      validator.on_message = lambda do |type, message|
        shell.say(type.upcase + ": " + message, type == 'warn' ? :yellow : :red)
      end

      if validator.validate!
        shell.say("All OK!", :green)
      end
    end

    desc 'build', 'Build the current extension'
    method_option :output_dir, :type => :string, :default => 'build',
      :aliases => '-o', :banner => 'The directory to build in'
    method_option 'tayfile', :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    def build
      spec = get_specification
      builder = Builder.new(spec, File.dirname(tayfile_path), File.expand_path(options[:output_dir]))
      builder.build!
    end

    protected

    def get_specification(path = nil)
      path ||= tayfile_path

      unless File.exist?(path)
        if options[:tayfile].nil?
          message = "No Tayfile was found in the current directory"
        else
          message = "#{path} does not exist"
        end
        raise SpecificationNotFound.new(message)
      end

      eval(File.open(path).read)
    end

    def tayfile_path
      File.expand_path(options[:tayfile] || DEFAULT_TAYFILE)
    end
  end
end