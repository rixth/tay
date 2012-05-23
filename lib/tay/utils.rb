module Tay
  ##
  # Simple helpers used across various classes
  class Utils
    ##
    # Convert an extension name to a filesystem friendly name
    def self.filesystem_name(name)
      name.gsub(/[^a-zA-Z0-9\-_ ]/, '').gsub(/ /, '_').downcase
    end

    ##
    # Convert a path to be relative to pwd
    def self.relative_path_to(path)
      if path.is_a?(String)
        path = Pathname.new(path)
      end
      path.relative_path_from(Pathname.new(Dir.pwd))
    end

  end
end