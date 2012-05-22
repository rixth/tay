require 'bundler/setup'
require 'thor'

module Tay
  ##
  # Runs tay's command line interface
  class CLI < ::Thor
    DEFAULT_TAYFILE = 'Tayfile'

    include ::Thor::Actions

    def self.source_root
      File.expand_path('templates', File.dirname(__FILE__))
    end

    desc 'new NAME', 'Create a new extension in directory NAME'
    method_option 'no-gitignore', :type => :boolean, :default => false,
      :banner => "Don\t create a .gitignore file"
    method_option 'no-gemfile', :type => :boolean, :default => false,
      :banner => "Don\t create a Gemfile file"
    method_option 'browser-action', :type => :boolean, :default => false,
      :banner => "Create a browser action"
    method_option 'page-action', :type => :boolean, :default => false,
      :banner => "Create a page action"
    method_option 'content-script', :type => :boolean, :default => false,
      :banner => "Create a content script"
    def new(name)
      outdir = Utils.filesystem_name(name)
      create_directory_structure(outdir)

      template('Gemfile', File.join(outdir, 'Gemfile')) unless options['no-gemfile']
      copy_file('gitignore', File.join(outdir, '.gitignore')) unless options['no-gitignore']
      template('Tayfile', File.join(outdir, 'Tayfile'), {
        'name' => name
      }.merge(options))

      directory('browser_action', File.join(outdir, 'src')) if options['browser-action']
      directory('page_action', File.join(outdir, 'src')) if options['page-action']
      directory('content_script', File.join(outdir, 'src')) if options['content-script']
    end

    desc 'validate', 'Validate the current extension'
    method_option :tayfile, :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    method_option 'built-directory', :type => :string, :default => 'build',
      :aliases => '-b', :banner => 'The directory containing the built extension'
    def validate
      spec = get_specification
      build_dir = File.expand_path(options['built-directory'], File.dirname(tayfile_path))

      validator = SpecificationValidator.new(spec, build_dir)
      validator.on_message = lambda do |type, message|
        shell.say(type.upcase + ": " + message, type == 'warn' ? :yellow : :red)
      end

      if validator.validate!
        shell.say("All OK!", :green)
      end
    end

    desc 'build', 'Build the current extension'
    method_option 'output-dir', :type => :string, :default => 'build',
      :aliases => '-o', :banner => 'The directory to build in'
    method_option :tayfile, :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    def build
      spec = get_specification
      builder = Builder.new(spec, File.dirname(tayfile_path), File.expand_path(options['output-dir']))
      builder.build!
    end

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
          shell.say('ERROR: please add the uglifier gem to your Gemfile to minfy javascripts', :red)
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
          shell.say('ERROR: please add the yui-compressor gem to your Gemfile to minfy css files', :red)
        end
      end
    end

    desc 'package', 'Package the current extension'
    method_option :tayfile, :type => :string,
      :banner => 'Use the specified tayfile instead of Tayfile'
    method_option 'built-directory', :type => :string, :default => 'build',
      :aliases => '-b', :banner => 'The directory containing the built extension'
    method_option 'type', :type => 'string', :default => 'zip',
      :aliases => '-t', :banner => 'The file type to build, zip or crx'
    def package
      unless %{zip crx} .include?(options['type'])
        raise InvalidPackageType.new("Invalid package type '#{options['type']}'")
      end

      spec = get_specification
      base_dir = File.dirname(tayfile_path)
      build_dir = File.expand_path(options['built-directory'], base_dir)

      packager = Packager.new(spec, base_dir, build_dir)

      if packager.private_key_exists?
        shell.say("Using private key at #{Utils.relative_path_to(packager.full_key_path)}", :green)
      else
        shell.say("Creating private key at #{Utils.relative_path_to(packager.full_key_path)}", :yellow)
        packager.write_new_key
      end

      empty_directory(File.join(base_dir, 'pkg'), :verbose => false)
      filename = Utils.filesystem_name(spec.name) + '-' + spec.version + '.' + options['type']
      package_path = Pathname.new(File.join(base_dir, 'pkg', filename))
      relative_package_path = Utils.relative_path_to(package_path)

      if package_path.exist? && shell.no?("#{relative_package_path} exists, overwrite?")
        shell.say("Aborting...", :yellow)
        exit 1
      end

      package_path.unlink if package_path.exist?
      packager.send("write_#{options['type']}".to_sym, package_path)
      shell.say("Wrote #{package_path.size} bytes to #{relative_package_path}", :green)
    end

    protected

    def get_specification(path = nil)
      path ||= tayfile_path

      unless File.exist?(path)
        if options[:tayfile].nil?
          message = "No Tayfile was found in the current directory"
        else
          message = "#{path} does not exist"
        end
        raise SpecificationNotFound.new(message)
      end

      eval(File.open(path).read)
    end

    def tayfile_path
      File.expand_path(options[:tayfile] || DEFAULT_TAYFILE)
    end

    def create_directory_structure(outdir)
      empty_directory(outdir)
      empty_directory(File.join(outdir, 'src'))
      empty_directory(File.join(outdir, 'src/assets'))
      empty_directory(File.join(outdir, 'src/html'))
      empty_directory(File.join(outdir, 'src/javascripts'))
      empty_directory(File.join(outdir, 'src/stylesheets'))
    end
  end
end