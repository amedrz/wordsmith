class Wordsmith
  module Generate
    
    attr_reader :files, :output
    
    # generate the new media
    def generate(args = [])
      @output = local(File.join('final', @name))
      
      content_dir = local(File.join('content'))
      @files = Dir.glob(content_dir + '/**/*.*').join(" \\\n")
      
      if @files.empty?
        raise "Exiting.. Nothing to generate in #{content_dir}"
      end
      
      build_metadata_xml
      
      @stylesheet = if @config["stylesheet"] && File.exists?(local(@config["stylesheet"]))
        local(@config["stylesheet"])
      end
      
      Dir.mkdir(local('final')) unless File.exists?(local('final'))
      
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
      header = if File.exists?(local(File.join('layout', 'header.html')))
        local(File.join('layout', 'header.html'))
      end
      footer = if File.exists?(local(File.join('layout', 'footer.html')))
        local(File.join('layout', 'footer.html'))
      end
      cmd = "pandoc -s -S --toc -o #{@output}.html -t html"
      cmd += " -c #{@stylesheet}" if @stylesheet
      cmd += " -B #{header}" if header
      cmd += " -A #{footer}" if footer
      cmd += " \\\n#{@files}"
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