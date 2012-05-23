module Tay
  module CLI
    class Root < ::Thor
      desc 'build', 'Build the current extension'
      method_option 'output-dir', :type => :string, :default => 'build',
        :aliases => '-o', :banner => 'The directory to build in'
      method_option :tayfile, :type => :string,
        :banner => 'Use the specified tayfile instead of Tayfile'
      def build
        spec = get_specification
        builder = Builder.new(spec, tayfile_path.dirname, Pathname.new(options['output-dir']).expand_path)
        builder.build!
      end
    end
  end
end