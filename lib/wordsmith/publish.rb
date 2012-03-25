require "git"

module Git
  class Lib
    # overwrites https://github.com/schacon/ruby-git/blob/master/lib/git/lib.rb#L486-493
    def checkout(branch, opts = {})
      arr_opts = []
      arr_opts << '-f' if opts[:force]
      arr_opts << '-b' << opts[:new_branch] if opts[:new_branch]
      arr_opts << "-- #{opts[:path]}" if opts[:path]
      arr_opts << branch

      command('checkout', arr_opts)
    end
  end
end

class Wordsmith

  module Publish

    # publish compiled html files to a
    # Github project page
    def publish(from_path = "final/#{@name}/*/**")

      @base = Git.open(local(".git"))

      # Create gh-pages branch if necessary
      if !@base.branches.local.collect{ |a| a.to_s }.include?("gh-pages")
        create_gh_pages_branch
      end

      # Copy html files from master branch
      @base.lib.checkout("master", :path => from_path)

      # add, commit and push changes, then get back to master
      @base.add(".")
      @base.commit("changes to #{@name} public site.")
      @base.push("origin", "gh-pages")
      @base.checkout("master")
    end

    private

    # Creates a repository's github page
    # according to the instructions given at
    # http://pages.github.com/#project_pages
    def create_gh_pages_branch
      @base.lib.change_head_branch("gh-pages")
      `rm .git/index`
      `git clean -fdx`
    end
  end
end
