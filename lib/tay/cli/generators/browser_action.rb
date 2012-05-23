module Tay
  module CLI
    class Generate < ::Thor
      desc "browser_action", "Generate a browser action"
      def browser_action
        copy_file('browser_action/action.js', javascript_dir.join('browser_action.js'))
        copy_file('browser_action/action.css', stylesheet_dir.join('browser_action.css'))
        copy_file('browser_action/action.html', html_dir.join('browser_action.html'))
        inject_tayfile_content(File.read(find_in_source_paths('browser_action/tayfile_content')))
      end
    end
  end
end