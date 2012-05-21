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
      sprockets_compile_directory('scripts')
      sprockets_compile_directory('styles')
      write_manifest
    end

    protected

    ##
    # Given a path, run it through tilt and return the compiled version.
    # If there's no known engine for it, just return the content verbatim.
    # If we know the type buy are missing the gem, raise an exception.
    def get_compiled_file_content(path)
      begin
        [File.basename(path).sub(/\.[a-z]+\Z/, ''), Tilt.new(path).render]
      rescue LoadError
        file = $!.message.scan(/cannot load such file -- (.*)/)
        raise GemNotInstalled.new("Could not load the gem to compile #{file}, is it installed?")
      rescue RuntimeError
        [File.basename(path), File.read(path)]
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
        file_out_dir = File.dirname(src_path_to_out_path(path))
        filename, content = get_compiled_file_content(path)

        FileUtils.mkdir_p(file_out_dir)
        File.open(file_out_dir + '/' + filename, 'w') do |f|
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
        file_out_dir = File.dirname(src_path_to_out_path(path))

        if @sprockets.extensions.include?(File.extname(path))
          logical_path = path.sub(/\A#{@base_dir}\//, '')
          content = @sprockets[logical_path].to_s
        else
          content = File.read(path)
        end

        FileUtils.mkdir_p(file_out_dir)
        File.open(file_out_dir + '/' + File.basename(path), 'w') do |f|
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

    class GemNotInstalled < RuntimeError; end
  end
end