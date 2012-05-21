module Tay
  class Specification
    ##
    # A packaged app is included on the user's New Tab screen. They cannot have
    # page or browser actions.
    #
    # http://code.google.com/chrome/extensions/apps.html
    class PackagedApp
      ##
      # When your app is launched, this is the path to the HTML file that will
      # be loaded
      attr_accessor :launch_page

      attr_reader :container
      attr_reader :width, :height

      ##
      # If you app should appear in its own panel, call this method, supplying
      # the width and height of said panel
      def appears_in_panel(width, height)
        @container = 'panel'
        @width = width
        @height = height
      end

      ##
      # If you app should appear in a standard tab (default) call this method.
      def appears_in_tab
        @container = 'tab'
      end
    end
  end
end