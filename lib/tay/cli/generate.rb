module Tay
  module CLI
    class Generate < ::Thor
      include ::Thor::Actions
      include Tay::CLI::Helpers

      class_option 'tayfile', :type => :string,
        :banner => 'Use the specified tayfile instead of Tayfile'
      class_option 'build-directory', :type => :string, :default => 'build',
        :aliases => '-b', :banner => 'The directory containing the built extension'

      def self.source_root
        File.expand_path('generators/templates', File.dirname(__FILE__))
      end

      require 'tay/cli/generators/page_action'
      require 'tay/cli/generators/browser_action'
      require 'tay/cli/generators/content_script'
      require 'tay/cli/generators/options_page'

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
      # Render a template in the context of self and return its contents
      # Thor does not provide a way to do this.
      def render_template(path, locals = {})
        path = path.to_s

        # Try to use a haml file path if available
        if path[/\.html$/] && using_haml?
          begin
            if find_in_source_paths(path + '.haml')
              path = path + '.haml'
            end
          rescue Exception
          end
        end

        tayfile_template = Tilt::ERBTemplate.new(find_in_source_paths(path), {
          :trim => '-'
        })
        tayfile_template.render(self, locals)
      end

      ##
      # Automatically use the coffeescript/haml templates when copying a file
      # if the user has the gems in their gemfile
      def copy_file(from, to)
        from = from.to_s
        to = to.to_s

        if from[/\.js$/] && using_coffeescript?
          from = from + '.coffee'
          to = to + '.coffee'
        end

        if from[/\.html$/] && using_haml?
          from = from + '.haml'
          to = to + '.haml'
        end

        super(from, to)
      end

      ##
      # Create a file, tacking on .haml if we're using it
      def create_file(path, content, *args)
        path = path.to_s
        if path[/\.html$/] && using_haml?
          path = path + '.haml'
        end

        super
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