require 'thor'

module Tay
  ##
  # Runs tay's command line interface
  class CLI < ::Thor
    DEFAULT_TAYFILE = 'Tayfile'

    include ::Thor::Actions

    def self.source_root
      File.expand_path('cli/templates', File.dirname(__FILE__))
    end

    protected

    def get_specification(path = nil)
      path = path ? Pathname.new(path) : tayfile_path

      unless path.exist?
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
      Pathname.new(options[:tayfile] || DEFAULT_TAYFILE).expand_path
    end
  end
end

require 'tay/cli/new'
require 'tay/cli/build'
require 'tay/cli/validate'
require 'tay/cli/minify'
require 'tay/cli/package'