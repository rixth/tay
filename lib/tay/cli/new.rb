module Tay
  class CLI < ::Thor
    desc 'new NAME', 'Create a new extension'
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

    protected

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