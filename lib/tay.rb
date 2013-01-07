require 'bundler/setup'

require 'fileutils'
require 'pathname'
require 'json'

require 'tay/version'
require 'tay/utils'
require 'tay/specification'
require 'tay/specification_validator'
require 'tay/manifest_generator'
require 'tay/builder'
require 'tay/packager'

module Tay
  class InvalidSpecification < Exception; end
  class SpecificationNotFound < Exception; end
  class InvalidPackageType < Exception; end
  class PrivateKeyNotFound < Exception; end
end
