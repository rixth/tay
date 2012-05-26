module Tay
  module CLI
    module Helpers
      DEFAULT_TAYFILE = 'Tayfile'

      protected

      def spec(bust_cache = false)
        @spec = nil if bust_cache
        @spec ||= get_specification
      end

      def get_specification(path = nil)
        path = path ? Pathname.new(path) : tayfile_path

        unless path.exist?
          if options['tayfile'].nil?
            message = "No Tayfile was found in the current directory"
          else
            message = "#{path} does not exist"
          end
          raise SpecificationNotFound.new(message)
        end

        eval(File.open(path).read)
      end

      def tayfile_path
        Pathname.new(options['tayfile'] || DEFAULT_TAYFILE).expand_path
      end

      ##
      # Return the base directory for this extension
      def base_dir
        tayfile_path.dirname
      end

      ##
      # Return the src directory for this extension
      def src_dir
        base_dir.join('src')
      end

      ##
      # Return the build directory for this extension, respecting any command
      # line option
      def build_dir
        base_dir.join(options['build-directory'] || 'build')
      end

      ##
      # Detect if the user has coffee-script in their Gemfile
      def using_coffeescript?
        Gem.loaded_specs.keys.include?('coffee-script')
      end

      ##
      # Detect if the user has haml in their Gemfile
      def using_haml?
        Gem.loaded_specs.keys.include?('haml')
      end
    end
  end
end