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

module Tay
  module CLI
    class Generate < ::Thor
      desc "content_script", "Generate a content script"
      method_option 'script-name', :type => :string, :default => 'content_script',
        :aliases => '-n', :banner => 'The name of the content script'
      method_option 'no-javascript', :type => :boolean, :default => false,
        :banner => "Don\t create a javascript file"
      method_option 'no-stylesheet', :type => :boolean, :default => false,
        :banner => "Don\t create a stylesheet"
      def content_script
        fs_name = Utils.filesystem_name(options['script-name'])

        unless options['no-javascript']
          copy_file('content_script/content_script.js', javascript_dir.join(fs_name + '.js'))
        end
        unless options['no-stylesheet']
          copy_file('content_script/content_script.css', stylesheet_dir.join(fs_name + '.css'))
        end
        inject_tayfile_content(render_template('content_script/tayfile', :fs_name => fs_name))
      end
    end
  end
end