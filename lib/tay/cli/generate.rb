module Tay
  module CLI
    class Generate < ::Thor
      include ::Thor::Actions
      include Tay::CLI::Helpers

      class_option :tayfile, :type => :string,
        :banner => 'Use the specified tayfile instead of Tayfile'
      class_option 'build-directory', :type => :string, :default => 'build',
        :aliases => '-b', :banner => 'The directory containing the built extension'

      def self.source_root
        File.expand_path('generators/templates', File.dirname(__FILE__))
      end

      require 'tay/cli/generators/page_action'
      require 'tay/cli/generators/browser_action'
      require 'tay/cli/generators/content_script'

      protected

      ##
      # Take some content and inject it inside the Tay::Specification
      def inject_tayfile_content(new_content)
        tayfile_contents = tayfile_path.read.strip
        tayfile_contents.sub!(/end\Z/, "\n" + new_content + "\nend")
        tayfile_path.open('w') do |f|
          f.write(tayfile_contents)
        end
      end

      ##
      # Get path to src/assets
      def asset_dir
        src_dir.join('assets')
      end

      ##
      # Get path to src/html
      def html_dir
        src_dir.join('html')
      end

      ##
      # Get path to src/stylesheets
      def stylesheet_dir
        src_dir.join('stylesheets')
      end

      ##
      # Get path to src/javascripts
      def javascript_dir
        src_dir.join('javascripts')
      end

      ##
      # Get path to the src directory
      def src_dir
        tayfile_path.dirname.join('src')
      end
    end
  end
end