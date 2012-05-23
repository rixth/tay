module Tay
  class CLI < ::Thor
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
        say("Using private key at #{Utils.relative_path_to(packager.full_key_path)}", :green)
      else
        say("Creating private key at #{Utils.relative_path_to(packager.full_key_path)}", :yellow)
        packager.write_new_key
      end

      empty_directory(File.join(base_dir, 'tmp'))
      empty_directory(File.join(base_dir, 'pkg'))

      temp_pkg_path = Pathname.new(File.join(base_dir, 'tmp', 'package'))
      temp_pkg_path.unlink if temp_pkg_path.exist?
      packager.send("write_#{options['type']}".to_sym, temp_pkg_path)

      filename = Utils.filesystem_name(spec.name) + '-' + spec.version + '.' + options['type']
      pkg_path = Pathname.new(File.join(base_dir, 'pkg', filename))

      copy_file(temp_pkg_path, pkg_path)
      say("Wrote #{pkg_path.size} bytes to #{Utils.relative_path_to(pkg_path)}", :green)
      temp_pkg_path.unlink
    end
  end
end
