require 'fileutils'
require 'json'
require 'tilt'
require 'sprockets'
require 'sprockets/commonjs'

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
      @base_dir = base_dir
      @output_dir = output_dir || (base_dir + "/build")
      create_sprockets_environment
    end

    ##
    # Do the building. This simply delegates to the private methods
    # in this class.
    def build!
      create_output_directory
      simple_compile_directory('html')
      simple_compile_directory('assets')
      sprockets_compile_directory('javascripts')
      sprockets_compile_directory('stylesheets')
      write_manifest
    end

    protected

    ##
    # Given a path, run it through tilt and return the compiled version.
    # If there's no known engine for it, just return the content verbatim.
    # If we know the type buy are missing the gem, raise an exception.
    def get_compiled_file_content(path)
      begin
        Tilt.new(path).render
      rescue LoadError
        file = $!.message.scan(/cannot load such file -- (.*)/)
        raise GemNotInstalled.new("Could not load the gem to compile #{file}, is it installed?")
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
      files = Dir[@base_dir + "/src/#{directory}/**/*"].map
      files.each do |path|
        file_out_path = src_path_to_out_path(path)
        content = get_compiled_file_content(path)

        FileUtils.mkdir_p(File.dirname(file_out_path))
        File.open(asset_output_filename(file_out_path, Tilt.mappings.keys), 'w') do |f|
          f.write content
        end
      end
    end

    ##
    # Process all the files in the directory through sprockets before writing
    # them to the output directory
    def sprockets_compile_directory(directory)
      files = Dir[@base_dir + "/src/#{directory}/**/*"].map
      files.each do |path|
        file_out_path = src_path_to_out_path(path)

        if @sprockets.extensions.include?(File.extname(path))
          logical_path = path.sub(/\A#{@base_dir}\//, '')
          content = @sprockets[logical_path].to_s
        else
          content = File.read(path)
        end

        FileUtils.mkdir_p(File.dirname(file_out_path))
        output_filename = asset_output_filename(file_out_path, @sprockets.engines.keys)
        File.open(output_filename, 'w') do |f|
          f.write content
        end
      end
    end

    ##
    # Generate the manifest from the spec and write it to disk
    def write_manifest
      generator = ManifestGenerator.new(spec)

      File.open(@output_dir + '/manifest.json', 'w') do |f|
        f.write JSON.pretty_generate(generator.spec_as_json)
      end
    end

    ##
    # Set up the sprockets environment for munging all the things
    def create_sprockets_environment
      @sprockets = Sprockets::Environment.new
      @sprockets.append_path(@base_dir + '/')
      @sprockets.register_preprocessor 'application/javascript', Sprockets::CommonJS
      # Please avert your eyes... gross hack due to sprockets 0.0.3 not working
      # out of the box without rails.
      @sprockets.append_path(File.dirname(Sprockets::CommonJS.method(:default_namespace).source_location[0]) + '/..')
    end

    ##
    # Debug message helper
    def dbg(msg)
      puts dbg if debug
    end

    ##
    # Helper function that converts a base_dir/src/XYZ path to the equivalent
    # path in the output directory
    def src_path_to_out_path(path)
      @output_dir + path.sub(/\A#{@base_dir}\/src/, '')
    end

    ##
    # Helper function to convert the filenames of assets requiring pre-
    # processing to their compiled extension. However, if the file only
    # has one extension, it will be left alone regardless. Examples:
    #
    # * "foobar.module.js.coffee" => "foobar.module.js"
    # * "index.html.haml" => "index.html"
    # * "style.scss" => "style.scss"
    def asset_output_filename(filename, processed_extensions)
      return filename if filename.split('.').length == 2

      extension = File.extname(filename)
      processed_extensions.map! { |ext| (ext[0] != '.' ? '.' : '') + ext }

      if processed_extensions.include?(extension)
        asset_output_filename(filename.sub(/#{extension}\Z/, ''), processed_extensions)
      else
        filename
      end
    end

    class GemNotInstalled < RuntimeError; end
  end
end