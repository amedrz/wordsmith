require File.expand_path "../test_helper", __FILE__

context "wordsmith sass tests" do

  def wordsmith
    Wordsmith.new
  end

  test "compiles sass files" do
    in_temp_dir do
      wordsmith.init('w')
      Dir.chdir("w") { wordsmith.generate ["html"] }

      sass1 = File.read("w/assets/stylesheets/_partial.scss")
      sass2 = File.read("w/assets/stylesheets/_with_sass.scss")
      compiled_css = File.read("w/final/w/assets/stylesheets/master.css")

      assert compiled_css =~ /#{sass1.split("\n").first}/
      assert compiled_css =~ /#{sass2.split("\n").first}/
    end
  end

  test "doesn't copy sass assets to final" do
    in_temp_dir do
      wordsmith.init('w')
      Dir.chdir("w") { wordsmith.generate ["html"] }

      files = Dir.glob('w/final/**/*')

      assert files.include?("w/final/w/assets/stylesheets/master.css")
      assert files.include?("w/final/w/assets/stylesheets/other.css")

      assert files.grep(/.scss$/).empty?
    end
  end

  test "includes compiled css files inside final html" do
    in_temp_dir do
      wordsmith.init('w')
      assert File.exists?("w/assets/stylesheets/master.scss")

      Dir.chdir("w") { wordsmith.generate ["html"] }
      html_content = File.read("w/final/w/index.html")

      assert html_content =~ /master.css/
    end
  end

end
