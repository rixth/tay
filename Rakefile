#!/usr/bin/env rake
require "bundler/gem_tasks"

task :build_generators do
  require 'tilt'
  require 'haml'
  require 'coffee-script'

  templates_dir = Pathname.new('lib//tay/cli/generators/templates').expand_path(File.dirname(__FILE__))
  Dir[templates_dir.join('**/*.coffee')].each do |cs_path|
    File.open(cs_path.sub(/\.coffee/, ''), 'w') do |f|
      f.write Tilt.new(cs_path).render
    end
  end

  Dir[templates_dir.join('**/*.haml')].each do |haml_path|
    File.open(haml_path.sub(/\.haml/, ''), 'w') do |f|
      html = Tilt.new(haml_path).render
      # We need to fix the ERB tags which have been encoded
      html = html.gsub(/%&gt;/, '%>').gsub(/&lt;%/, '<%')
      f.write html
    end
  end
end

task :doc do
  `sdoc`
end