class Wordsmith
  module Generate
    
    attr_reader :files, :output
    
    # generate the new media
    def generate(args = [])
      @output = File.join(WORDSMITH_ROOT, 'final', @name)
      
      content_dir = File.join(WORDSMITH_ROOT, 'content')
      @files = Dir.glob(content_dir + '/**/*.*').join(" \\\n")
      
      if @files.empty?
        info "Exiting.. Nothing to generate in #{WORDSMITH_ROOT}"
        return false
      end
      
      build_metadata_xml
      
      @stylesheet = if @config["stylesheet"] && File.exists?(File.join(WORDSMITH_ROOT, @config["stylesheet"]))
        File.join(WORDSMITH_ROOT, @config["stylesheet"])
      end
      
      formats = args.empty? ? OUTPUT_TYPES : args
      formats.each do |format|
        if respond_to?("to_#{format}")
          if format == 'mobi'
            out = to_mobi
          else
            out = run_command(send("to_#{format}"))
          end
          if $?.exitstatus == 0 && out == '' || $?.exitstatus == 1 && format == 'mobi'
            info "Created #{@output}.#{format}"
          else
            raise "#{format} generator failed"
          end
        else
          raise "No generator found for #{format}"
        end
      end
    end
    
    def build_metadata_xml
      metadata = File.join(WORDSMITH_ROOT, 'metadata.xml')
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
      header = if File.exists?(File.join(WORDSMITH_ROOT, 'layout', 'header.html'))
        File.join(WORDSMITH_ROOT, 'layout', 'header.html') 
      end
      footer = if File.exists?(File.join(WORDSMITH_ROOT, 'layout', 'footer.html'))
        File.join(WORDSMITH_ROOT, 'layout', 'footer.html')
      end
      cmd = "pandoc -s -S --toc -o #{@output}.html -t html"
      cmd += " -c #{@stylesheet}" if @stylesheet
      cmd += " -B #{header}" if header
      cmd += " -A #{footer}" if footer
      cmd += " \\\n#{@files}"
    end
    
    def to_epub
      info "Generating epub..."
      metadata = if File.exists?(File.join(WORDSMITH_ROOT, 'metadata.xml'))
        File.join(WORDSMITH_ROOT, 'metadata.xml')
      end
      cover = if @config["cover"] && File.exists?(File.join(WORDSMITH_ROOT, @config["cover"]))
        File.join(WORDSMITH_ROOT, @config["cover"]) 
      end
      cmd = "pandoc -S -o #{@output}.epub -t epub"
      cmd += " \\\n--epub-metadata=#{metadata}"
      cmd += " \\\n--epub-cover-image=#{cover}" if cover
      cmd += " \\\n--epub-stylesheet=#{@stylesheet}" if @stylesheet
      cmd += " \\\n#{@files}"
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
      "pandoc -N --toc -o #{@output}.pdf -t pdf #{@files}"
    end
    
    def run_command(cmd)
      `#{cmd}`.strip
    end
    
  end
end