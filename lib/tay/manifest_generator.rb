module Tay
  ##
  # Takes a Tay::Specification and turns it in to a JSON representation
  # that is eventually saved in to the manifest.json file.
  #
  # It also does basic sanity checks for missing required fields and common
  # mistakes.
  class ManifestGenerator
    ##
    # Pointer to the relevant Tay::Specification
    attr_reader :spec

    def initialize(specification)
      @spec = specification
    end

    ##
    # Check for missing required fields and common property collisons
    def validate
      def fail(msg)
        raise Tay::Specification::InvalidSpecification.new(msg)
      end

      fail("No name provided") unless spec.name
      fail("No version provided") unless spec.version

      fail("No icons provided") if spec.icons.keys.empty?

      if spec.packaged_app
        fail("You cannot use packaged apps and page actions") if spec.page_action
        fail("You cannot use packaged apps and browser actions") if spec.browser_action
      end
    end

    ##
    # Return the JSON representation of the specification
    def spec_as_json
      json = {
        :name => spec.name,
        :version => spec.version,
        :manifest_version => calculate_manifest_version
      }

      json[:description] = spec.description if spec.description
      json[:icons] = spec.icons
      json[:default_locale] = spec.default_locale if spec.default_locale
      json[:browser_action] = action_as_json(spec.browser_action) if spec.browser_action
      json[:page_action] = action_as_json(spec.page_action) if spec.page_action
      json[:app] = packaged_app_as_json if spec.packaged_app
      json[:background] = spec.background_page if spec.background_page
      json[:chrome_url_overrides] = spec.overriden_pages unless spec.overriden_pages.empty?
      json[:content_scripts] = content_scripts_as_json unless spec.content_scripts.empty?
      json[:content_security_policy] = spec.content_security_policy if spec.content_security_policy
      json[:homepage_url] = spec.homepage if spec.homepage
      json[:incognito] = spec.incognito_mode if spec.incognito_mode
      json[:intents] = web_intents_as_json unless spec.web_intents.empty?
      json[:minimum_chrome_version] = spec.minimum_chrome_version if spec.minimum_chrome_version
      json[:nacl_modules] = nacl_modules_as_json unless spec.nacl_modules.empty?
      json[:offline_enabled] = spec.offline_enabled unless spec.offline_enabled.nil?
      json[:omnibox] = spec.omnibox_keyword if spec.omnibox_keyword
      json[:options_page] = spec.options_page if spec.options_page
      json[:permissions] = spec.permissions unless spec.permissions.empty?
      json[:requirements] = requirements_as_json if has_requirements?
      json[:update_url] = spec.update_url if spec.update_url
      json[:web_accessible_resources] = spec.web_accessible_resources unless spec.web_accessible_resources.empty?

      json
    end

    protected

    ##
    # Work out which manifest version needed based on the features that have
    # been used
    def calculate_manifest_version
      return 2 unless spec.web_accessible_resources.empty?
      1
    end

    ##
    # Return the manifest representation of a page or browser action
    def action_as_json(action)
      {
        :default_title => action.title,
        :default_icon => action.icon,
        :default_popup => action.popup
      }
    end

    ##
    # Return the manifest representation of a packaged app
    def packaged_app_as_json
      app = spec.packaged_app
      json = {
        :local_path => app.page
      }

      unless app.container.nil?
        json[:container] = app.container
        if app.container == 'panel'
          json[:width] = app.width
          json[:height] = app.height
        end
      end

      json
    end

    ##
    # Return the manifest representation of the content scripts, if any
    def content_scripts_as_json
      spec.content_scripts.map do |cs|
        cs_json = {
          :matches => cs.include_patterns
        }

        cs_json[:exclude_matches] = cs.exclude_patterns unless cs.exclude_patterns.empty?
        cs_json[:run_at] = cs.run_at if cs.run_at
        cs_json[:all_frames] = cs.all_frames unless cs.all_frames.nil?
        cs_json[:css] = cs.stylesheets unless cs.stylesheets.empty?
        cs_json[:js] = cs.scripts unless cs.scripts.empty?

        cs_json
      end
    end

    ##
    # Return the manifest representation of handled web intents, if any
    def web_intents_as_json
      spec.web_intents.map do |wi|
        {
          :action => wi.action,
          :title => wi.title,
          :href => wi.href,
          :types => wi.types,
          :disposition => wi.disposition
        }
      end
    end

    ##
    # Return the manifest representation of native client modules, if any
    def nacl_modules_as_json
      spec.nacl_modules.map do |nm|
        {
          :path => nm.path,
          :mime_type => nm.mime_type
        }
      end
    end

    ##
    # Return the manifest representation of any technology requirements
    def requirements_as_json
      features = []
      features << 'webgl' if spec.requires_webgl
      features << 'css3d' if spec.requires_3d_css_transitions

      {
        '3D' => {
          :features => features
        }
      }
    end

    ##
    # Calculates if the manifest should have a requirements field
    def has_requirements?
      spec.requires_webgl || spec.requires_3d_css_transitions
    end

  end
end