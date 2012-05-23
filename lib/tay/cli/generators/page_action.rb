module Tay
  module CLI
    class Generate < ::Thor
      desc "page_action", "Generate a page action"
      def page_action
        copy_file('page_action/icon.png', asset_dir.join('page_action_icon.png'))
        copy_file('page_action/controller.js', javascript_dir.join('page_action_controller.js'))
        inject_tayfile_content(File.read(find_in_source_paths('page_action/tayfile_content')))
      end
    end
  end
end