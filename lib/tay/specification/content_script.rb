module Tay
  class Specification
    ##
    # Represents a content script in your extension. For more information on
    # valid values for attributes and pattern specications, check the docs.
    #
    # http://code.google.com/chrome/extensions/content_scripts.html
    class ContentScript
      ##
      # Specifies when to inject and run this content script.
      attr_accessor :run_at

      ##
      # Should this content script run in every frame on a page?
      attr_accessor :all_frames

      ##
      # An array of patterns to include this content script on
      attr_accessor :include_patterns

      ##
      # An array of patterns to exclude this content script on
      attr_accessor :exclude_patterns

      ##
      # An array of stylesheet paths to inject
      attr_accessor :stylesheets

      ##
      # An array of script paths to inject
      attr_accessor :scripts

      def initialize
        @include_patterns = []
        @exclude_patterns = []
        @scripts = []
        @stylesheets = []
      end
    end
  end
end