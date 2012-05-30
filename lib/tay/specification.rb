require 'tay/specification/action'
require 'tay/specification/page_action'
require 'tay/specification/browser_action'
require 'tay/specification/packaged_app'
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
    attr_accessor :nacl_modules

    ##
    # An array of Tay::Specification::ContentScript objects
    attr_accessor :content_scripts

    ##
    # An array of Tay::Specification::WebIntent objects
    attr_accessor :web_intents

    ##
    # An array javascript file paths that will run in the background
    #
    # http://code.google.com/chrome/extensions/background_pages.html
    attr_accessor :background_scripts

    ##
    # An array of paths considered "web accessible"
    #
    # http://code.google.com/chrome/extensions/manifest.html#web_accessible_resources
    attr_accessor :web_accessible_resources

    ##
    # An array of permissions the extension requires
    #
    # http://code.google.com/chrome/extensions/manifest.html#permissions
    attr_accessor :permissions

    ##
    # An array of javascript paths that will be copied to the build
    attr_accessor :javascripts

    ##
    # An array of stylesheet paths that will be copied to the build
    attr_accessor :stylesheets

    ##
    # An map of icon sizes to paths
    #
    # http://code.google.com/chrome/extensions/manifest.html#icons
    attr_accessor :icons

    ##
    # A map of Chrome page types to HTML files
    attr_reader :overriden_pages

    ##
    # A Tay::Specification::BrowserAction or nil
    attr_reader :browser_action

    ##
    # A Tay::Specification::PageAction or nil
    attr_reader :page_action

    ##
    # A Tay::Specification::PackagedApp or nil
    attr_reader :packaged_app

    ##
    # An array of directories that will be copied to the build directory.
    # Defaults to "img", "assets", and "html", all files are run through
    # Tilt before being copied
    #
    # If just a directory name is passed, it is assumed to be a sub-dir
    # of src, and will be copied as the directory name, eg:
    #
    # spec.source_directories << "extras"
    #   # copies src/extras to build/extras
    #
    # If you provide a path, it is relative to the root directory, and will be
    # copied to the build directory under this full relative path, eg:
    #
    # spec.source_directories << "non_code/fonts"
    #   # copies non_code/fonts to build/non_code/fonts
    #
    # If you need finer control over where files end up, you can also push an
    # object on to this list detailing the source directory, and the directory
    # it will be placed in under the build dir. You can optionally specify
    # whether to run through Tilt or not (default: yes). eg:
    #
    # spec.source_directories << {
    #   :from => "vendor/bootstrap/img",
    #   :as => "img",
    #   :use_tilt => false
    # }  # copies vendor/bootstrap/img/* to build/img
    attr_accessor :source_directories

    ##
    # The path to the private key used to package this extension. Will default
    # to ./EXTNAME.pem
    attr_accessor :key_path

    def initialize(&block)
      @nacl_modules = []
      @overriden_pages = {}
      @web_accessible_resources = []
      @permissions = []
      @background_scripts = []
      @content_scripts = []
      @web_intents = []
      @icons = {}
      @stylesheets = []
      @javascripts = []
      @source_directories = %w{img assets html}

      yield self
    end

    ##
    # Provide the path of the icon to be used at a certain size
    def add_icon(size, path)
      @icons[size.to_i] = path
    end

    ##
    # Create a new Tay::Specification::BrowserAction and pass it to the block
    # for set up.
    def add_browser_action(&block)
      raise Tay::InvalidSpecification.new('Browser action already set up') if @browser_action
      @browser_action = BrowserAction.new
      yield @browser_action
    end

    ##
    # Create a new Tay::Specification::BrowserAction and pass it to the block
    # for set up.
    def add_page_action(&block)
      raise Tay::InvalidSpecification.new('Page action already set up') if @page_action
      @page_action = PageAction.new
      yield @page_action
    end

    ##
    # Create a new Tay::Specification::BrowserAction and pass it to the block
    # for set up.
    def add_packaged_app(&block)
      raise Tay::InvalidSpecification.new('Packaged app already set up') if @packaged_app
      @packaged_app = PackagedApp.new
      yield @packaged_app
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
    # Override a built in Chrome page with your own HTML file
    #
    # http://code.google.com/chrome/extensions/override.html
    def override_page(page_type, path)
      @overriden_pages[page_type] = path
    end

    ##
    # Return all the javascript paths in the spec, included those nested
    # inside other objects
    def all_javascript_paths
      all_paths = []
      all_paths += @javascripts
      all_paths += @background_scripts
      all_paths += @content_scripts.map { |cs| cs.javascripts }.compact
      all_paths.flatten.uniq
    end

    ##
    # Return all the stylesheet paths in the spec, included those nested
    # inside other objects
    def all_stylesheet_paths
      all_paths = []
      all_paths += @stylesheets
      all_paths += @content_scripts.map { |cs| cs.stylesheets }.compact
      all_paths.flatten.uniq
    end

    ##
    # Get the path to the private key for this extension
    def key_path
      @key_path || Utils.filesystem_name(name) + '.pem'
    end

    ##
    # Does the specification have a certain permission?
    def has_permission?(permission)
      permissions.include?(permission)
    end
  end
end