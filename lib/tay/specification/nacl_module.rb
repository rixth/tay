module Tay
  class Specification
    ##
    # Used to map a mime-type to a native client module
    #
    # * http://code.google.com/chrome/extensions/manifest.html#nacl_modules
    # * http://code.google.com/chrome/nativeclient/docs/technical_overview.html
    class NaClModule
      ##
      # Path to the .nmf file for your module
      attr_accessor :path

      ##
      # The mime-type that will load your module
      attr_accessor :mime_type
    end
  end
end