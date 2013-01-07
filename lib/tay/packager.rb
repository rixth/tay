require 'crxmake'

module Tay
  ##
  # Takes a Tay::Specification and builds it. It compiles the assets,
  # writes the manifest, and copies everything to the output path.
  class Packager
    ##
    # Pointer to the relevant Tay::Specification
    attr_reader :spec

    ##
    # Create a new builder. You must pass the specification, full path to the
    # source directory and an optional output directory which defaults to
    # base_dir + '/build'
    def initialize(specification, base_dir, build_dir)
      @spec = specification
      @base_dir = Pathname.new(base_dir)
      @build_dir = Pathname.new(build_dir)
    end

    ##
    # Write a signed zip file to out_path for upload to the Web Store
    def write_zip(out_path)
      CrxMake.zip(
        :ex_dir => @build_dir,
        :pkey   => full_key_path,
        :zip_output => out_path,
        :verbose => false
      )
    end

    ##
    # Write a signed crx file to out_path for self hosting
    def write_crx(out_path)
      CrxMake.make(
        :ex_dir => @build_dir,
        :pkey   => full_key_path,
        :crx_output => out_path,
        :verbose => false
      )
    end

    ##
    # Calculate the extension's ID from the key
    # Core concepts from supercollider.dk
    def extension_id
      raise Tay::PrivateKeyNotFound.new unless private_key_exists?

      public_key = OpenSSL::PKey::RSA.new(File.read(full_key_path)).public_key.to_der
      hash = Digest::SHA256.hexdigest(public_key)[0...32]
      hash.unpack('C*').map{ |c| c < 97 ? c + 49 : c + 10 }.pack('C*')
    end

    ##
    # Do we have an existing key file?
    def private_key_exists?
      full_key_path.exist?
    end

    ##
    # Return the absolute path to the private key
    def full_key_path
      Pathname.new(spec.key_path).expand_path(@base_dir)
    end

    ##
    # Generate a key with OpenSSL and write it to the key path
    def write_new_key
      File.open(full_key_path, 'w') do |f|
        f.write OpenSSL::PKey::RSA.generate(1024).export()
      end
    end
  end
end