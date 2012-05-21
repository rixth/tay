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
      attr_reader :include_patterns

      ##
      # An array of patterns to exclude this content script on
      attr_reader :exclude_patterns

      ##
      # An array of stylesheet paths to inject
      attr_reader :stylesheets

      ##
      # An array of script paths to inject
      attr_reader :scripts

      def initialize
        @include_patterns = []
        @exclude_patterns = []
        @scripts = []
        @stylesheets = []
      end

      ##
      # Add a URL pattern on which this content script will run
      def add_include_pattern(pattern)
        @include_patterns << pattern
      end

      ##
      # Add a URL pattern on which this content script will not run
      def add_exclude_pattern(pattern)
        @exclude_patterns << pattern
      end

      ##
      # Add a path to the list of scripts that will be injected
      def add_script(path)
        @scripts << path
      end

      ##
      # Add a path to the list of stylesheets that will be injected
      def add_stylesheet(path)
        @stylesheets << path
      end
    end
  end
end