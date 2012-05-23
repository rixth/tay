module Tay
  class CLI < ::Thor
    desc 'minify', 'Validate the currently built extension'
    method_option 'built-directory', :type => :string, :default => 'build',
      :aliases => '-b', :banner => 'The directory containing the built extension'
    method_option :tayfile, :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    method_option 'skip-js', :type => :boolean, :default => false,
      :banner => "Don't minify *.js files"
    method_option 'skip-css', :type => :boolean, :default => false,
      :banner => "Don't minify *.css files"
    def minify
      build_dir = File.expand_path(options['built-directory'], File.dirname(tayfile_path))

      unless options['skip-js']
        begin
          require 'uglifier'
          Dir[File.join(build_dir, '**/*.js')].each do |path|
            content = File.read(path)
            File.open(path, 'w') do |f|
              f.write Uglifier.compile(content)
            end
          end
        rescue LoadError
          say('ERROR: please add the uglifier gem to your Gemfile to minfy javascripts', :red)
        end
      end

      unless options['skip-css']
        begin
          require 'yui/compressor'
          Dir[File.join(build_dir, '**/*.css')].each do |path|
            content = File.read(path)
            File.open(path, 'w') do |f|
              f.write YUI::CssCompressor.new.compress(content)
            end
          end
        rescue LoadError
          say('ERROR: please add the yui-compressor gem to your Gemfile to minfy css files', :red)
        end
      end
    end
  end
end