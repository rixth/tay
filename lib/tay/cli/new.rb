module Tay
  module CLI
    class Root < ::Thor
      desc 'new NAME', 'Create a new extension'
      method_option 'no-gitignore', :type => :boolean, :default => false,
        :banner => "Don\'t create a .gitignore file"
      method_option 'no-gemfile', :type => :boolean, :default => false,
        :banner => "Don\'t create a Gemfile file"
      method_option 'use-coffeescript', :type => :boolean, :default => false,
        :banner => "Use coffeescript"
      method_option 'use-haml', :type => :boolean, :default => false,
        :banner => "Use haml"
      def new(name)
        outdir = Pathname.new(Utils.filesystem_name(name))
        create_directory_structure(outdir)

        template('Gemfile', outdir.join('Gemfile')) unless options['no-gemfile']
        copy_file('gitignore', outdir.join('.gitignore')) unless options['no-gitignore']
        template('Tayfile', outdir.join('Tayfile'), {
          'name' => name
        }.merge(options))
      end

      protected

      def create_directory_structure(outdir)
        empty_directory(outdir)
        empty_directory(outdir.join('src'))
        empty_directory(outdir.join('src/assets'))
        empty_directory(outdir.join('src/html'))
        empty_directory(outdir.join('src/javascripts'))
        empty_directory(outdir.join('src/stylesheets'))
        empty_directory(outdir.join('src/templates'))
      end
    end
  end
end