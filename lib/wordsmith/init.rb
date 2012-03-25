class Wordsmith
  module Init
    
    # start a new wordsmith directory with skeleton structure
    def init(args = [])
      name = Array(args).shift
      raise "needs a directory name" unless name
      raise "directory already exists" if File.exists?(name)

      info "Creating wordsmith directory structure in #{name}"
      template_dir = File.join(WORDSMITH_ROOT, 'template')
      ign = Dir.glob(template_dir + '/.[a-z]*')
      FileUtils.cp_r template_dir, name
      
      # also copy files that start with .
      FileUtils.cp_r ign, name
      if Git.init(local(name))
        info "Initialized empty Git repository in #{File.join(local(name), '.git')}"
        @git = Git.open(local(name))
        @git.add '.'
        info "git add ."
        @git.commit 'initial commit'
        info "git commit -m 'initial commit'"
      end
    end
  end
end