require 'thor'
require 'thor/group'
require 'tay/cli/helpers'

module Tay
  ##
  # Runs tay's command line interface
  module CLI
    class Root < ::Thor
      include ::Thor::Actions
      include ::Tay::CLI::Helpers

      require 'tay/cli/new'
      require 'tay/cli/build'
      require 'tay/cli/generate'
      require 'tay/cli/validate'
      require 'tay/cli/minify'
      require 'tay/cli/package'
    end
  end
end