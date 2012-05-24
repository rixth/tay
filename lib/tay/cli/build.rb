module Tay
  module CLI
    class Root < ::Thor
      desc 'build', 'Build the current extension'
      method_option 'tayfile', :type => :string,
        :banner => 'Use the specified tayfile instead of Tayfile'
      method_option 'build-directory', :type => :string, :default => 'build',
        :aliases => '-b', :banner => 'The directory to build in'
      def build
        builder = Builder.new(spec, base_dir, build_dir)
        builder.build!
      end
    end
  end
end