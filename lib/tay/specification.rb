require 'tay/specification/action'
require 'tay/specification/page_action'
require 'tay/specification/browser_action'
require 'tay/specification/pakaged_app'
require 'tay/specification/content_script'
require 'tay/specification/web_intent'
require 'tay/specification/nacl_module'

module Tay
  ##
  # A tay specification helps you define the functionality that the extension
  # provides. It also serves as the data source that it used to generate the
  # manifest.json file.
  class Specification
    ##
    # http://code.google.com/chrome/extensions/manifest.html#name
    attr_accessor :name

    ##
    # http://code.google.com/chrome/extensions/manifest.html#version
    attr_accessor :version

    ##
    # http://code.google.com/chrome/extensions/manifest.html#description
    attr_accessor :description

    ##
    # http://code.google.com/chrome/extensions/manifest.html#homepage_url
    attr_accessor :homepage

    ##
    # http://code.google.com/chrome/extensions/manifest.html#default_locale
    attr_accessor :default_locale

    ##
    # Path to an HTML file that will be used as the background page
    attr_accessor :background_page

    ##
    # http://code.google.com/chrome/extensions/manifest.html#options_page
    attr_accessor :options_page

    ##
    # http://code.google.com/chrome/extensions/omnibox.html
    attr_accessor :omnibox_keyword

    ##
    # http://code.google.com/chrome/extensions/contentSecurityPolicy.html
    attr_accessor :content_security_policy

    ##
    # http://code.google.com/chrome/extensions/manifest.html#minimum_chrome_version
    attr_accessor :minimum_chrome_version

    ##
    # http://code.google.com/chrome/extensions/manifest.html#incognito
    attr_accessor :incognito_mode

    ##
    # http://code.google.com/chrome/extensions/manifest.html#offline_enabled
    attr_accessor :offline_enabled

    ##
    # Set this to true to mark the extension as requiring webgl support
    attr_accessor :requires_webgl

    ##
    # Set this to true to mark the extension as requiring 3d css support
    attr_accessor :requires_3d_css_transitions

    ##
    # http://code.google.com/chrome/extensions/autoupdate.html
    attr_accessor :update_url

    ##
    # If you set this to a hash, it will be merged on top of the generated
    # manifest. This is useful to force override of specific values
    attr_accessor :manifest_data

    ##
    # An array of Tay::Specification::NaClModule
    attr_reader :nacl_modules

    ##
    # An array of Tay::Specification::ContentScript objects
    attr_reader :content_scripts

    ##
    # An array of paths of script files that will run in the background
    attr_reader :background_scripts

    ##
    # An array of Tay::Specification::WebIntent objects
    attr_reader :web_intents

    ##
    # A map of Chrome page types to HTML files
    attr_reader :overriden_pages

    ##
    # An array of paths considered "web accessible"
    attr_reader :web_accessible_resources

    ##
    # An array of permissions the extension reqires
    attr_reader :permissions

    ##
    # An map of icon sizes to paths
    attr_reader :icons

    def initialize(&block)
      @nacl_modules = []
      @overriden_pages = {}
      @web_accessible_resources = []
      @permissions = []
      @background_scripts = []
      @content_scripts = []
      @web_intents = []
      @icons = {}

      yield self
    end

    def add_icon(size, path)
      @icons[size.to_i] = path
    end

    ##
    # If a block is given, a new Tay::Specification::BrowserAction will be
    # created and passed to the block for set up. If no block is given, the
    # current browser action (or nil) will be returned.
    def browser_action
      if block_given?
        @browser_action = BrowserAction.new
        yield @browser_action
      else
        @browser_action
      end
    end

    ##
    # If a block is given, a new Tay::Specification::PageAction will be
    # created and passed to the block for set up. If no block is given, the
    # current page action (or nil) will be returned.
    def page_action
      if block_given?
        @page_action = PageAction.new
        yield @page_action
      else
        @page_action
      end
    end

    ##
    # If a block is given, a new Tay::Specification::PackagedApp will be
    # created and passed to the block for set up. If no block is given, the
    # current app (or nil) will be returned.
    def packaged_app
      if block_given?
        @packaged_app = PackagedApp.new
        yield @packaged_app
      else
        @packaged_app
      end
    end

    ##
    # Add a content script to this extension. It will be passed to the block
    # for set up. See Tay::Specification::ContentScript
    def add_content_script(&block)
      content_script = ContentScript.new
      yield content_script
      @content_scripts << content_script
    end

    ##
    # Add a web intent to this extension. It will be passed to the block for
    # set up. See Tay::Specification::WebIntent
    def add_web_intent(&block)
      web_intent = WebIntent.new
      yield web_intent
      @web_intents << web_intent
    end

    ##
    # Add a native client module to this extension. It will be passed to the
    # block for set up. See Tay::Specification::NaClModule
    def add_nacl_module(&block)
      nacl_module = NaClModule.new
      yield nacl_module
      @nacl_modules << nacl_module
    end

    ##
    # Add a path to the list of scripts that run in the background
    def add_background_script(path)
      @background_scripts << path
    end

    ##
    # Add a permission to the list of requirements for this extension
    #
    # http://code.google.com/chrome/extensions/manifest.html#permissions
    def add_permission(permission)
      @permissions << permission
    end

    ##
    # Mark a path as "web accessible"
    #
    # http://code.google.com/chrome/extensions/manifest.html#web_accessible_resources
    def add_web_accessible_resource(path)
      @web_accessible_resources << path
    end

    ##
    # Override a built in Chrome page with your own HTML file
    #
    # http://code.google.com/chrome/extensions/override.html
    def override_page(page_type, path)
      @overriden_pages[page_type] = path
    end
  end
end