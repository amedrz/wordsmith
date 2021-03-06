require 'sass/plugin'

class Wordsmith
  module Generate
    attr_reader :config, :files, :name, :output

    def setup
      @name = File.basename(local("."))
      @config = YAML::parse(File.open(local(".wordsmith"))).
        transform rescue {}

      run_callback("before_all")
      content_dir = local(File.join("content"))
      @files = Dir.glob(content_dir + "/**/*.*").sort.join(" \\\n")

      if files.empty?
        raise "Exiting.. Nothing to generate in #{content_dir}." +
          "\nHave you run 'wordsmith new'?"
      end

      Dir.mkdir(local("final")) unless File.exists?(local("final"))
      @output = local(File.join("final", name))
    end

    def generate(args = [])
      setup

      formats = args.empty? ? OUTPUT_TYPES : args

      formats.each do |format|
        raise "No generator found for #{format}" unless respond_to?("to_#{format}")

        run_callback("before_#{format}")
        out = if format == "mobi"
          send("to_#{format}")
        else
          run_command(send("to_#{format}"))
        end
        run_callback("after_#{format}")

        if $?.exitstatus == 0 && out.empty? || format == "mobi" && $?.exitstatus == 1
          info "Created #{output}" +
            (format == "html" ? "/index.html" : ".#{format}")
        else
          raise "#{format} generator failed"
        end
      end
      run_callback("after_all")
    end

    def run_callback(meth)
      run_command(config[meth]) if config[meth]
    end

    def to_html
      info "Generating html..."

      compile_stylesheets
      copy_assets

      cmd = "pandoc -f markdown_mmd -s -S --toc -o #{File.join(output, "index.html")} -t html"
      stylesheets.each { |stylesheet| cmd += " -c #{stylesheet}" }
      cmd += " -B #{header}" if header
      cmd += " -A #{footer}" if footer
      cmd += " \\\n#{files}"
      cmd
    end

    def to_epub
      info "Generating epub..."

      build_metadata_xml

      cmd = "pandoc -f markdown_mmd -S -o #{output}.epub -t epub"
      cmd += " \\\n--epub-metadata=#{metadata}" if metadata
      cmd += " \\\n--epub-cover-image=#{cover}" if cover
      cmd += " \\\n--epub-stylesheet=#{epub_stylesheet}" if epub_stylesheet
      cmd += " \\\n#{files}"
      cmd
    end

    def to_mobi
      if File.exists?(output + ".epub")
        info "Generating mobi..."
        Kindlegen.run("#{output}.epub", "-o", "#{name}.mobi")
      else
        info "Skipping .mobi (#{name}.epub doesn't exist)"
      end
    end

    def to_pdf
      info "Generating pdf..."

      engine = ""

      [["xetex", "xelatex"], ["pdftex", "pdflatex"], "lualatex"].each do |e|
        if e.is_a? Array
          cmd, name = e
        else
          cmd = name = e
        end
        if can_run?(cmd + " -v")
          engine = name
          break
        end
      end

      cmd = "pandoc -f markdown_mmd -N --toc -o #{output}.pdf #{files}"
      cmd += " --latex-engine=#{engine}" unless engine.empty?
      cmd += " -V mainfont='#{config['font']}'" unless (config.fetch('font', '')).empty?
      cmd
    end

    private

    def build_metadata_xml
      metadata = local(File.join("metadata.xml"))

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.metadata("xmlns:dc" => "http://purl.org/dc/elements/1.1/") {
          xml["dc"].title { xml.text config["title"] }
          config["author"].split(/\s*;\s*/).each do |creator|
            xml["dc"].creator { xml.text creator }
          end if config["author"]
          xml["dc"].language { xml.text config["language"] }
        }
      end

      frg = Nokogiri::XML.fragment(builder.to_xml)
      nodes = frg.search(".//metadata/*")
      File.open(metadata, "w") { |f| f.write(nodes.to_xml) }
    end

    def compile_stylesheets
      unless defined?(SASS_LOADED)
        Sass::Plugin.reset!

        css_location = File.join(output, "assets", "stylesheets")
        sass_location = File.join(local("assets"), "stylesheets")

        Sass::Plugin.options.merge!(:template_location => sass_location,
          :css_location  => css_location,
          :always_update => false,
          :always_check  => true)
      end

      Sass::Plugin.on_updated_stylesheet do |template, css|
        info "Compiling #{template} to #{css}"
      end

      Sass::Plugin.update_stylesheets
    end

    def copy_assets
      assets = Dir.glob(File.join("assets", "**", "*"))
      sass = Dir.glob(File.join("assets", "stylesheets", "**", "*.scss"))

      copies = assets - sass - [epub_stylesheet_location]
      copies.each do |entry|
        dest = File.join(output, File.dirname(entry))
        FileUtils.mkdir_p dest
        FileUtils.cp entry, dest unless File.directory?(entry)
      end
    end

    def cover
      @cover ||= if config["cover"] && File.exists?(local(File.join(config["cover"])))
        local(File.join(config["cover"]))
      end
    end

    def epub_stylesheet
      @epub_stylesheet ||= if File.exists?(epub_stylesheet_location)
        local(epub_stylesheet_location)
      end
    end

    def epub_stylesheet_location
      File.join("assets", "stylesheets", "epub.css")
    end

    def footer
      @footer ||= if File.exists?(local(File.join("layout", "footer.html")))
        local(File.join("layout", "footer.html"))
      end
    end

    def header
      @header ||= if File.exists?(local(File.join("layout", "header.html")))
        local(File.join("layout", "header.html"))
      end
    end

    def metadata
      @metadata ||= if File.exists?(local(File.join("metadata.xml")))
        local(File.join("metadata.xml"))
      end
    end

    def stylesheets
      @stylesheet ||= begin
        styles = Dir.glob(File.join(output, "assets", "stylesheets", "**", "*.css"))
        partials = Dir.glob(File.join(output, "assets", "stylesheets", "**", "_*.css"))
        all = styles - partials - [epub_stylesheet_location]

        all.map { |css| css.gsub(output + "/", "") }
      end
    end

    def run_command(cmd)
      `#{cmd}`.strip
    end

    def can_run?(cmd)
      out = `#{cmd} 2>&1`
      info out
      $?.success?
    end
  end
end
