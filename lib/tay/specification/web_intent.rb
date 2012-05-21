module Tay
  class Specification
    ##
    # Represents a web intent that your extension provides. For more info
    # check the Google Chrome extension docs, and spec at the URLs below.
    #
    # * http://code.google.com/chrome/extensions/manifest.html#intents
    # * http://www.webintents.org/
    class WebIntent
      ##
      # The "title" is displayed in the intent picker UI when the user
      # initiates the action specific to the handler.
      attr_accessor :action

      ##
      # The "title" is displayed in the intent picker UI when the user
      # initiates the action specific to the handler.
      attr_accessor :title

      ##
      # The "title" is displayed in the intent picker UI when the user
      # initiates the action specific to the handler.
      attr_accessor :href

      ##
      # Intents with "window" disposition will open a new tab when invoked,
      # those with "inline" disposition will be displayed inside the intent
      # picker when invoked.
      attr_accessor :disposition

      ##
      # An array of mime types that can be handled
      attr_reader :types

      def initialize
        @types = []
      end

      ##
      # Add a mime type that your intent can act upon
      def add_type(type)
        @types << type
      end
    end
  end
end