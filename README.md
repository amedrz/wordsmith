## What is it about?

Wordsmith is a ruby Framework with a built in command-line toolset for
create, share, colaborate and publish e-books, guides, manuals, etc.

Through the command line interface, you can create a project repository
with a standard directory structure that allows you and your co-authors to
easily colaborate on writing.

The command line interface, also provides a set of commands for
exporting files in formats such PDF, pubi and publishing online.

## Installing

First of all, you should have [Pandoc](http://johnmacfarlane.net/pandoc/installing.html) 
installed in your system.

Next, install the wordsmith ruby gem.

    gem install wordsmith

Now you're good to go.

## Usage

Wordsmith uses the following folder structure

BOOK_NAME/
	layout/
		header.html
		footer.html

	assets/
		images/
			cover.jpg
		stylesheets/
			default.css
			BOOK_NAME.css	

	content/	
		01_title.markdown
		02_title.markdown
		03_title.markdown

	content/
		01_title/
			01_lorem.markdown
			02_ipsum.markdown

	final/
		BOOK_NAME.epub
		BOOK_NAME.html
		BOOK_NAME.format

	Makefile

The **layout** folder contains the minimum required files for publishing your content 
online with the default design.
The **assets** folder contains the images and stylesheets that your book uses.
In the **content** folder we have two options:
1. Write the content of each chapter in its own file (Default).
2. Create a folder for each chapter and write the file or files for each chapter.

The files in the **content** folder must be written using snake_case with the number of 
the chapter or section (for option 2) at the beginning (01_title.markdown).