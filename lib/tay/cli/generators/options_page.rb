  module Tay
    module CLI
      class Generate < ::Thor
        desc "options_page", "Generate an options page"
        def options_page
          copy_file('options_page/options.js', javascript_dir.join('options.js'))
          copy_file('options_page/options_page.js', javascript_dir.join('options_page.js'))
          copy_file('options_page/options_server.js', javascript_dir.join('options_server.js'))
          copy_file('options_page/options_page.css', stylesheet_dir.join('options_page.css'))

          create_file(html_dir.join('options_page.html'), render_template('options_page/options_page.html'))

          inject_tayfile_content(render_template('options_page/tayfile'))
        end
      end
    end
  end