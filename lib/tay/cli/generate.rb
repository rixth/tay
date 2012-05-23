module Tay
  module CLI
    class Generate < ::Thor
      include ::Thor::Actions
      include Tay::CLI::Helpers

      def self.source_root
        File.expand_path('generators/templates', File.dirname(__FILE__))
      end

      require 'tay/cli/generators/page_action'
    end
  end
end