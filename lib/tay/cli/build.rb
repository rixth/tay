module Tay
  class CLI < ::Thor
    desc 'build', 'Build the current extension'
    method_option 'output-dir', :type => :string, :default => 'build',
      :aliases => '-o', :banner => 'The directory to build in'
    method_option :tayfile, :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    def build
      spec = get_specification
      builder = Builder.new(spec, File.dirname(tayfile_path), File.expand_path(options['output-dir']))
      builder.build!
    end
  end
end
