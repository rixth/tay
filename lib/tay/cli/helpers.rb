module Tay
  module CLI
    module Helpers
      DEFAULT_TAYFILE = 'Tayfile'

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

      def inject_tayfile_content(new_content)
        tayfile_contents = File.read(tayfile_path)
        tayfile_contents.strip!
        tayfile_contents.sub!(/end\Z/, "\n" + new_content + "\nend")
        File.open(tayfile_path, 'w') do |f|
          f.write(tayfile_contents)
        end
      end
    end
  end
end