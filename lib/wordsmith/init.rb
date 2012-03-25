class Wordsmith
  module Init
    
    # start a new wordsmith directory with skeleton structure
    def init(args = [])
      name = Array(args).shift
      raise "needs a directory name" unless name
      raise "directory already exists" if File.exists?(name)

      info "inititalizing #{name}"
      template_dir = File.join(WORDSMITH_ROOT, 'template')
      ign = Dir.glob(template_dir + '/.[a-z]*')
      FileUtils.cp_r template_dir, name
      
      # also copy files that start with .
      FileUtils.cp_r ign, name
    end
  end
end