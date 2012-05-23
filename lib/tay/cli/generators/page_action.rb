module Tay
  module CLI
    class Generate < ::Thor
      desc "page_action", "Generate a page action"
      def page_action
        outdir = tayfile_path.dirname

        copy_file('page_action/icon.png', outdir.join('src/assets', 'page_action_icon.png'))
        copy_file('page_action/controller.js', outdir.join('src/javascript', 'page_action_controller.js'))
        inject_tayfile_content(File.read(File.expand_path('templates/page_action/tayfile_content', File.dirname(__FILE__))))
      end
    end
  end
end