module Tay
  ##
  # Simple helpers used across various classes
  class Utils
    ##
    # Convert an extension name to a filesystem friendly name
    def self.filesystem_name(name)
      name.gsub(/[^a-zA-Z0-9\-_ ]/, '').gsub(/ /, '_').downcase
    end

  end
end