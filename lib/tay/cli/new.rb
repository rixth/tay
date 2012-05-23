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
      outdir = Pathname.new(Utils.filesystem_name(name))
      create_directory_structure(outdir)

      template('Gemfile', outdir.join('Gemfile')) unless options['no-gemfile']
      copy_file('gitignore', outdir.join('.gitignore')) unless options['no-gitignore']
      template('Tayfile', outdir.join('Tayfile'), {
        'name' => name
      }.merge(options))

      directory('browser_action', outdir.join('src')) if options['browser-action']
      directory('page_action', outdir.join('src')) if options['page-action']
      directory('content_script', outdir.join('src')) if options['content-script']
    end

    protected

    def create_directory_structure(outdir)
      empty_directory(outdir)
      empty_directory(outdir.join('src'))
      empty_directory(outdir.join('src/assets'))
      empty_directory(outdir.join('src/html'))
      empty_directory(outdir.join('src/javascripts'))
      empty_directory(outdir.join('src/stylesheets'))
    end
  end
end