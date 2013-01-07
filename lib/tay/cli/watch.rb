module Tay
  module CLI
    class Root < ::Thor
      desc 'watch', 'Set up auto-compilation'
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

        template_path = "#{::Guard.locate_guard('tay')}/lib/guard/tay/templates/Guardfile"

        copy_file(template_path, File.expand_path('Guardfile', '.'))

        say('Auto-compilation is now set up. Run `guard` to start watching for changes.', :green)
      end
    end
  end
end