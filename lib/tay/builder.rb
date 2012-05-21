require 'fileutils'
require 'json'
require 'tilt'

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
    end

    ##
    # Do the building. This simply delegates to the private methods
    # in this class.
    def build!
      create_output_directory
      copy_static_assets
      compile_html_files
      compile_style_files
      compile_script_files
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
    # Compile all files in src/html to the output
    def compile_html_files
      files = Dir[@base_dir + '/src/html/**/*'].map
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
    # Blindly copy the src/styles directory to the output
    def compile_style_files
      style_directory = @base_dir + '/src/styles'
      if Dir.exist?(style_directory)
        FileUtils.cp_r(style_directory, @output_dir)
      end
    end

    ##
    # Blindly copy the src/scripts directory to the output
    def compile_script_files
      script_directory = @base_dir + '/src/scripts'
      if Dir.exist?(script_directory)
        FileUtils.cp_r(script_directory, @output_dir)
      end
    end

    ##
    # Copy src/assets to the output verbatim
    def copy_static_assets
      asset_directory = @base_dir + '/src/assets'
      if Dir.exist?(asset_directory)
        FileUtils.cp_r(asset_directory, @output_dir)
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