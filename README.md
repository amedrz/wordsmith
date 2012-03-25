## What is it about?

Wordsmith is a ruby Framework with a built in command-line toolset to create, share, publish and collaborate on e-books, guides, manuals, etc.

Through the command line interface, you can create a project repository with a standard directory structure that allows you and your co-authors to easily manage your content.

The command line interface provides a set of commands to export in the following formats:
  
  * epub
  * mobi
  * pdf
  * html

You can also publish your book to your github project page with a single command.

By the way, Wordsmith was heavily based on [git-scribe][gitscribe] gem but with a few
extra goodies, such as painless installation.

[gitscribe]: https://github.com/schacon/git-scribe

## Installing

First of all, you should have [Pandoc][pandoc] installed in your system.

[pandoc]: http://johnmacfarlane.net/pandoc/installing.html

Next, install the wordsmith ruby gem.

    $ gem install wordsmith

Now you're good to go.

## Usage

    $ wordsmith new [book name]

After that, Wordsmith will create a default directory structure so you just need to start
creating your own content without worrying about anything else.

	book/
	  .wordsmith
		layout/
			header.html
			footer.html
		assets/
			images/
				cover.jpg
			stylesheets/
				default.css
				book.css	
		content/	
			01_chapter_one.md
			02_chapter_two.md
			03_chapter_three/
				01_lorem.md
				02_ipsum.md
		final/
			book.epub
			book.mobi
			book.pdf
			book/index.html

You can edit your book metadata inside the **.wordsmith** file:

    ---
    edition:    0.1
    language:   en
    author:     Your Name
    title:      Your Book Title
    cover:      assets/images/cover.jpg
    stylesheet: assets/stylesheets/default.css

The **layout** directory contains the header and footer for an online version of your book.

The **assets** directory contains images and stylesheets.

In the **content** directory you can:

1. write content as single files
* use directories to easily manage long chapters

**Please note** that the file names in the 'content' folder must be snake cased and begin with the number of the chapter or section (e.g. 01_chapter_one.md).

## To generate your book in different formats:

    $ wordsmith generate [ |html|epub|mobi|pdf] 
    (don't pass any option to generate all formats at once)

## Publishing your books

You can also publish a pretty neat html version of your book/manual/guide/etc. in github:

    $ wordsmith publish git@github.com:jassa/wordsmith-example.git
  
This will be available in a site like http://jassa.github.com/wordsmith-example/

## REMEMBER
Git is an important part of this tool, a typical workflow should look like this:

    $ wordsmith new ruby_guide
    // this command will also create a git repository 
    // and the first commit, but IT WILL NOT BE PUSHED YET
    // since you haven't provided a remote ref
    
    $ cd ruby_guide
    // Here you edit your 'content' directory with your own chapters
    
    // then when you are ready to commit you do it normally:
    $ wordsmith generate
    $ git commit -am "finished chapter one"
    
    // if you're not ready to publish to github pages, add a ref to a new repo
    $ git add remote origin git@github.com:jassa/wordsmith-example.git
    $ git push origin master
    
    // and if you are ready, you could do instead:
    $ wordsmith publish git@github.com:jassa/wordsmith-example.git

    // This will create a branch called 'gh-pages' as github requires,
    // you'll still need to run $ git push origin master 
    // to push your book editables
