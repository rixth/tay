module Tay
  module CLI
    class Root < ::Thor
      desc 'watch', 'Watch the current extension and recompile on file change'
      method_option :tayfile, :type => :string,
        :banner => 'Use the specified tayfile instead of Tayfile'
      method_option 'build-directory', :type => :string, :default => 'build',
        :aliases => '-b', :banner => 'The directory to build in'
      def watch
        begin
          require 'guard'
          require 'guard/tay'
        rescue LoadError
          say('ERROR: please add the guard and guard-tay gems to your Gemfile to enable auto compilation', :red)
          return
        end

        guardfile_path= "#{::Guard.locate_guard('tay')}/lib/guard/tay/templates/Guardfile"
        guardfile = File.read(guardfile_path)

        # Proxy in our command line options
        guardfile.sub!(':tay do', ":tay, #{options.to_s} do")

        Guard.setup
        Guard.start(:guardfile_contents => guardfile)
      end
    end
  end
end