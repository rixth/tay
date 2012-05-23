module Tay
  module CLI
    class Generate < ::Thor
      desc "page_action", "Generate a page action"
      method_option 'action-name', :type => :string, :default => 'Page Action',
        :aliases => '-n', :banner => 'The name of the page action'
      def page_action
        raise Tay::InvalidSpecification.new("Page action already specified") if spec.page_action
        raise Tay::InvalidSpecification.new("You cannot have both page and browser actions") if spec.browser_action
        raise Tay::InvalidSpecification.new("You cannot have both page actions and packaged apps") if spec.packaged_app

        fs_name = Utils.filesystem_name(options['action-name'])
        copy_file('page_action/icon.png', asset_dir.join(fs_name + '_icon.png'))
        copy_file('page_action/controller.js', javascript_dir.join(fs_name + '_controller.js'))
        inject_tayfile_content(render_template('page_action/tayfile', :fs_name => fs_name))
      end
    end
  end
end