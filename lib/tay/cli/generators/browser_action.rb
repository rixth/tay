module Tay
  module CLI
    class Generate < ::Thor
      desc "browser_action", "Generate a browser action"
      method_option 'action-name', :type => :string, :default => 'Browser Action',
        :aliases => '-n', :banner => 'The name of the browser action'
      def browser_action
        raise Tay::InvalidSpecification.new("Browser action already specified") if spec.browser_action
        raise Tay::InvalidSpecification.new("You cannot have both browser and page actions") if spec.browser_action
        raise Tay::InvalidSpecification.new("You cannot have both browser actions and packaged apps") if spec.packaged_app

        fs_name = Utils.filesystem_name(options['action-name'])
        copy_file('browser_action/action.js', javascript_dir.join(fs_name+ '.js'))
        copy_file('browser_action/action.css', stylesheet_dir.join(fs_name+ '.css'))

        create_file(html_dir.join(fs_name + '.html'), render_template('browser_action/action.html', :fs_name => fs_name))

        inject_tayfile_content(render_template('browser_action/tayfile', :fs_name => fs_name))
      end
    end
  end
end