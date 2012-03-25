require 'nokogiri'
require 'kindlegen'

class Wordsmith
  module Generate
    
    attr_reader :files, :output
    
    # generate the new media
    def generate(args = [])
      @output = File.join(WORDSMITH_ROOT, 'final', @name)
      content_dir = File.join(WORDSMITH_ROOT, 'content')
      @files = Dir.glob(content_dir + '/**/*.*').join("\n")
      build_metadata_xml
      OUTPUT_TYPES.each do |format|
        out = run_command(send("to_#{format}").strip) if respond_to?("to_#{format}")
        if $?.exitstatus > 0
          if $?.exitstatus == 1 && out == ''
            info "[Done] #{@output}.#{format}"
          end
          raise "Generate#to_#{format} failed"
        end
      end
      out
    end
    
    def build_metadata_xml
      metadata_xml = File.join(WORDSMITH_ROOT, 'metadata.xml')
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.root('xmlns:dc' => 'http://purl.org/dc/elements/1.1/') {
          xml['dc'].title { xml.text @config["title"] }
          xml['dc'].creator { xml.text @config["author"] }
          xml['dc'].language { xml.text @config["language"] }
        }
      end
      File.open(metadata_xml, 'w') { |f| f.write(builder.to_xml) }
    end
    
    def to_html
      info "Generating html..."
      header = File.join(WORDSMITH_ROOT, 'layout/header.html')
      footer = File.join(WORDSMITH_ROOT, 'layout/footer.html')
      stylesheet = File.join(WORDSMITH_ROOT, @config["stylesheet"])
      "pandoc -s -S --toc -c #{stylesheet} -B #{header} -A #{footer} #{@files} -o #{@output} -t html"
    end
    
    def to_epub
      info "Generating epub..."
      metadata_xml = File.join(WORDSMITH_ROOT, 'metadata.xml')
      stylesheet = File.join(WORDSMITH_ROOT, @config["stylesheet"])
      cover = File.join(WORDSMITH_ROOT, @config["cover"])
      <<-eos
        pandoc -S #{@files} -o #{@output} -t epub
        --epub-metadata=#{metadata_xml}
        --epub-cover-image=#{cover}
        --epub-stylesheet=#{stylesheet}
      eos
    end
    
    def to_mobi
      if File.exists?(@output + '.epub')
        info "Generating mobi..."
        Kindlegen.run("#{@output}.epub", "-o", "#{@output}.mobi")
      else
        info "Skipping .mobi (#{@name}.epub doesn't exist)"
      end
    end
    
    def to_pdf
      info "Generating pdf..."
      "pandoc -N #{@files} --toc -o #{@output} -t pdf"
    end
    
    def run_command(cmd)
      IO.popen(cmd + ' 2>&1')
      Process.wait
    end
    
  end
end