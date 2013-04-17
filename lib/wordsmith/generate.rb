class Wordsmith
  module Generate

    attr_reader :files, :output

    # generate the new media
    def generate(args = [])
      @config = YAML::parse(File.open(local('.wordsmith'))).
        transform rescue {}

      @output = local(File.join('final', @name))
      content_dir = local(File.join('content'))

      @files = Dir.glob(content_dir + '/**/*.*').sort.join(" \\\n")
      if @files.empty?
        raise "Exiting.. Nothing to generate in #{content_dir}.\nHave you run 'wordsmith new'?"
      end

      @stylesheet = if @config["stylesheet"] && File.exists?(local(@config["stylesheet"]))
        local(@config["stylesheet"])
      end

      build_metadata_xml
      Dir.mkdir(local('final')) unless File.exists?(local('final'))

      formats = args.empty? ? OUTPUT_TYPES : args
      formats.each do |format|
        raise "No generator found for #{format}" unless respond_to?("to_#{format}")

        if format == 'mobi'
          out = to_mobi
        else
          out = run_command(send("to_#{format}"))
        end

        if $?.exitstatus == 0 && out == '' || $?.exitstatus == 1 && format == 'mobi'
          if format == 'html'
            info "Created #{@output}/index.html"
          else
            info "Created #{@output}.#{format}"
          end
        else
          raise "#{format} generator failed"
        end
      end
    end

    def build_metadata_xml
      metadata = local(File.join('metadata.xml'))

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.metadata('xmlns:dc' => 'http://purl.org/dc/elements/1.1/') {
          xml['dc'].title { xml.text @config["title"] }
          xml['dc'].creator { xml.text @config["author"] }
          xml['dc'].language { xml.text @config["language"] }
        }
      end

      frg = Nokogiri::XML.fragment(builder.to_xml)
      nodes = frg.search('.//metadata/*')
      File.open(metadata, 'w') { |f| f.write(nodes.to_xml) }
    end

    def to_html
      info "Generating html..."

      html_dir = local(File.join('final', @name))
      Dir.mkdir(html_dir) unless File.exists?(html_dir)

      header = if File.exists?(local(File.join('layout', 'header.html')))
        local(File.join('layout', 'header.html'))
      end

      footer = if File.exists?(local(File.join('layout', 'footer.html')))
        local(File.join('layout', 'footer.html'))
      end

      `cp -r #{base(File.join('template', 'assets'))} #{html_dir}`

      cmd = "pandoc -s -S --toc -o #{File.join(html_dir, 'index.html')} -t html"
      cmd += " -c #{@config['stylesheet']}" if @stylesheet
      cmd += " -B #{header}" if header
      cmd += " -A #{footer}" if footer
      cmd += " \\\n#{@files}"
      cmd
    end

    def to_epub
      info "Generating epub..."

      metadata = if File.exists?(local(File.join('metadata.xml')))
        local(File.join('metadata.xml'))
      end

      cover = if @config["cover"] && File.exists?(local(File.join(@config["cover"])))
        local(File.join(@config["cover"]))
      end

      cmd = "pandoc -S -o #{@output}.epub -t epub"
      cmd += " \\\n--epub-metadata=#{metadata}"
      cmd += " \\\n--epub-cover-image=#{cover}" if cover
      cmd += " \\\n--epub-stylesheet=#{@stylesheet}" if @stylesheet
      cmd += " \\\n#{@files}"
      cmd
    end

    def to_mobi
      if File.exists?(@output + '.epub')
        info "Generating mobi..."
        Kindlegen.run("#{@output}.epub", "-o", "#{@name}.mobi")
      else
        info "Skipping .mobi (#{@name}.epub doesn't exist)"
      end
    end

    def to_pdf
      info "Generating pdf..."

      engine = ''
      [['pdftex', 'pdflatex'], ['xetex', 'xelatex'], 'lualatex'].each do |e|
        if e.is_a? Array
          cmd, name = e
        else
          cmd = name = e
        end
        if can_run?(cmd + ' -v')
          engine = name
          break
        end
      end

      cmd = "pandoc -N --toc -o #{@output}.pdf #{@files}"
      cmd += " --latex-engine=#{engine}" unless engine == ''
      cmd
    end

    def run_command(cmd)
      `#{cmd}`.strip
    end

    def can_run?(cmd)
      `#{cmd} 2>&1`
      $?.success?
    end
  end
end
