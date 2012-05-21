module Tay
  class Specification
    ##
    # Action is a parent class shared between Tay::Specification::PageAction
    # and Tay::Specification::BrowserAction.
    class Action
      ##
      # Path to the icon that is displayed in the browser
      attr_accessor :icon
      ##
      # Title that appears on mouseover
      attr_accessor :title
      ##
      # Path to the HTML file that is displayed when your action is clicked
      attr_accessor :popup
    end
  end
end