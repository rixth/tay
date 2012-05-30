require 'tilt'
require 'sprockets'

module Tay
  ##
  # Takes a Tay::Specification and builds it. It compiles the assets,
  # writes the manifest, and copies everything to the output path.
  class Builder
    ##
    # Pointer to the relevant Tay::Specification
    attr_reader :spec

    ##
    # Set to true for debug output
    attr_accessor :debug

    ##
    # Create a new builder. You must pass the specification, full path to the
    # source directory and an optional output directory which defaults to
    # base_dir + '/build'
    def initialize(specification, base_dir, output_dir = nil)
      @spec = specification
      @base_dir = Pathname.new(base_dir)
      @output_dir = output_dir ? Pathname.new(output_dir) : @base_dir.join('build')
      create_sprockets_environment
    end

    ##
    # Do the building. This simply delegates to the private methods
    # in this class.
    def build!
      create_output_directory
      spec.source_directories.each { |d| simple_compile_directory(d) }
      compile_files(spec.all_javascript_paths)
      compile_files(spec.all_stylesheet_paths)
      write_manifest
    end

    ##
    # This is sub-optimal but the mustache/js gem does not require its tilt
    # template automatically.
    def self.try_to_load_mustache_trimmer
      begin
        require 'tilt/mustache_js_template'
        Sprockets.register_engine '.mustache', Tilt::MustacheJsTemplate
      rescue LoadError
      end
    end

    protected

    ##
    # Given a path, run it through tilt and return the compiled version.
    # If there's no known engine for it, just return the content verbatim.
    # If we know the type buy are missing the gem, raise an exception.
    def get_compiled_file_content(path)
      begin
        Tilt.new(path.to_s).render
      rescue RuntimeError
        File.read(path)
      end
    end

    ##
    # Create the output directory if it does not exist
    def create_output_directory
      FileUtils.mkdir_p @output_dir
    end

    ##
    # Copy all the files from a directory to the output, compiling
    # them if they are familiar to us. Does not do any sprocketing.
    def simple_compile_directory(directory)
      if directory.is_a?(String)
        # If we just have a single dirname, assume it's under src
        from_directory = (directory[/\//] ? '' : 'src/') + directory

        directory = {
          :from => from_directory,
          :as => directory
        }
      end

      directory[:use_tilt] |= true

      Dir[@base_dir.join(directory[:from], '**/*')].each do |path|
        file_in_path = Pathname.new(path)

        next unless file_in_path.file?

        file_out_path = remap_path_to_build_directory(path, directory)

        if directory[:use_tilt]
          content = get_compiled_file_content(file_in_path)
          file_out_path = asset_output_filename(file_out_path, Tilt.mappings.keys)
        else
          content = File.read(file_in_path)
        end

        FileUtils.mkdir_p(file_out_path.dirname)
        File.open(file_out_path, 'w') do |f|
          f.write content
        end
      end
    end

    ##
    # Process all the files in the directory through sprockets before writing
    # them to the output directory
    def compile_files(files)
      files.each do |base_path|
        # We do this second glob in case the path provided in the tayfile
        # references a compiled version
        Dir[@base_dir.join('src', base_path + '*')].each do |path|
          path = Pathname.new(path).relative_path_from(@base_dir.join('src'))
          file_in_path = @base_dir.join('src', path)
          file_out_path = asset_output_filename(@output_dir.join(path), @sprockets.engines.keys)

          if @sprockets.extensions.include?(path.extname)
            content = @sprockets[file_in_path].to_s
          else
            content = File.read(file_in_path)
          end

          FileUtils.mkdir_p(file_out_path.dirname)
          File.open(file_out_path, 'w') do |f|
            f.write content
          end
        end
      end
    end

    ##
    # Generate the manifest from the spec and write it to disk
    def write_manifest
      generator = ManifestGenerator.new(spec)

      File.open(@output_dir.join('manifest.json'), 'w') do |f|
        f.write JSON.pretty_generate(generator.spec_as_json)
      end
    end

    ##
    # Set up the sprockets environment for munging all the things
    def create_sprockets_environment
      @sprockets = Sprockets::Environment.new
      @sprockets.append_path(@base_dir.join('src/javascripts').to_s)
      @sprockets.append_path(@base_dir.join('src/templates').to_s)
      @sprockets.append_path(@base_dir.join('src/stylesheets').to_s)
      @sprockets.append_path(@base_dir.join('src').to_s)
      @sprockets.append_path(@base_dir.to_s)
    end

    ##
    # Debug message helper
    def dbg(msg)
      puts dbg if debug
    end

    ##
    # Helper function that converts a source path to an equivalent path in the
    # output directory
    def remap_path_to_build_directory(path, directory_info)
      base_directory = @base_dir.join(directory_info[:from]).to_s
      @output_dir.join(path.to_s.sub(/\A#{base_directory}\/?/, directory_info[:as] + '/'))
    end

    ##
    # Helper function to convert the filenames of assets requiring pre-
    # processing to their compiled extension. However, if the file only
    # has one extension, it will be left alone regardless. Examples:
    #
    # * "foobar.module.js.coffee" => "foobar.module.js"
    # * "index.html.haml" => "index.html"
    # * "style.scss" => "style.scss"
    def asset_output_filename(path, processed_extensions)
      path = Pathname.new(path) if path.is_a?(String)

      return path if path.basename.to_s.split('.').length == 2

      extension = path.extname
      processed_extensions.map! { |ext| (ext[0] != '.' ? '.' : '') + ext }

      if processed_extensions.include?(extension)
        asset_output_filename(path.to_s.sub(/#{extension}\Z/, ''), processed_extensions)
      else
        path
      end
    end
  end

  Builder.try_to_load_mustache_trimmer
end