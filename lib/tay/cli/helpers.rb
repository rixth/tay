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
    end
  end
end