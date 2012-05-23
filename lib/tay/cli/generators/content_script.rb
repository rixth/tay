module Tay
  module CLI
    class Generate < ::Thor
      desc "content_script", "Generate a content script"
      def content_script
        copy_file('content_script/content_script.js', javascript_dir.join('content_script.js'))
        copy_file('content_script/content_script.css', stylesheet_dir.join('content_script.css'))
        inject_tayfile_content(File.read(find_in_source_paths('content_script/tayfile_content')))
      end
    end
  end
end