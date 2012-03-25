## What is it about?

Wordsmith is a ruby Framework with a built in command-line toolset to
create, share, publish and collaborate on e-books, guides, manuals, etc.

Through the command line interface, you can create a project repository
with a standard directory structure that allows you and your co-authors 
to easily manage your content.

The command line interface provides a set of commands to export 
in the following formats:
  
  * epub
  * mobi
  * pdf
  * html

You can also publish your book to your github project page with a single command.

## Installing

First of all, you should have [Pandoc][pandoc] installed in your system.

[pandoc]: http://johnmacfarlane.net/pandoc/installing.html

Next, install the wordsmith ruby gem.

    gem install wordsmith

Now you're good to go.

## Usage

Wordsmith uses the following directory structure

	book/
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
			book_html/
		Makefile

The **layout** directory contains the header and footer for an online version of your book.

The **assets** directory contains images and stylesheets.

In the **content** directory you can:

1. write content as single files
* use directories to easily manage long chapters

**Please note** that the file names in the 'content' folder must be snake cased and begin with the number of
the chapter or section (e.g. 01_chapter_one.md).