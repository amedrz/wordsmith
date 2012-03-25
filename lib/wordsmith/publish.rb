class Wordsmith
  module Publish

    # publish html book to github project page
    def publish(args = [])
      options = args.first

      @git = Git.open(local('.'))
      
      if options =~ /\.git/ && !@git.remotes.map(&:to_s).include?('origin')
        @git.add_remote 'origin', options
        info "Added remote origin #{options}"
      elsif !@git.remotes.map(&:to_s).include?('origin')
        raise "You must add a remote origin.\ne.g: wordsmith publish git@github.com:jassa/wordsmith-example.git" 
      end

      if @git.current_branch != 'master'
        begin
          @git.checkout 'master'
          info "Switched to branch 'master'"
        rescue
          raise "You must be in the 'master' branch to publish"
        end
      end

      html_dir = File.join('final', @name)

      unless File.exists?(File.join(html_dir, 'index.html'))
        raise "Exiting.. Nothing to publish.\nHave you run 'wordsmith generate'?"
      end

      # http://pages.github.com/#project_pages
      `git symbolic-ref HEAD refs/heads/gh-pages`
      info "Switched to branch 'gh-pages'"
      `rm .git/index`
      `git clean -fdx`
      info "Removed files"        
      `git checkout master #{html_dir}`
      info "Copied files from 'master' #{html_dir}"
      `mv #{html_dir}/* ./`
      `rm -r final/`
      `git add .`
      `git rm -r final/*`
      begin
        @git.commit 'updating project page'
        info "git commit -m 'updating project page'"
      rescue Exception => e
        if e.to_s =~ /nothing to commit/
          raise 'Already up to date. Nothing to commit.'
        else
          raise e
        end
      end
      @git.push 'origin', 'gh-pages'
      info "git push origin gh-pages"
      @git.checkout 'master'
    rescue Exception => e
      @git.checkout 'master' rescue nil
      raise e
    end
  end
end
