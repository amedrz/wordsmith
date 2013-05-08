require File.expand_path "../test_helper", __FILE__

context "wordsmith css tests" do

  def wordsmith
    Wordsmith.new
  end

  test "copies all css files into final assets directory" do
    in_temp_dir do
      wordsmith.init('w')

      File.rename "w/assets/stylesheets/master.scss",
        "w/assets/stylesheets/_a_css_partial.css"

      Dir.chdir("w") { wordsmith.generate ["html"] }
      files = Dir.glob('w/final/**/*')

      assert files.include? "w/final/w/assets/stylesheets/other.css"
      assert files.include? "w/final/w/assets/stylesheets/_a_css_partial.css"
    end
  end

  test "includes all final css files inside output html" do
    in_temp_dir do
      wordsmith.init('w')

      File.rename "w/assets/stylesheets/master.scss",
        "w/assets/stylesheets/master.css"

      FileUtils.cp "w/assets/stylesheets/master.css",
        "w/assets/stylesheets/_a_css_partial.css"

      assert File.exists?("w/assets/stylesheets/other.css")

      Dir.chdir("w") { wordsmith.generate ["html"] }
      html_content = File.read("w/final/w/index.html")

      assert html_content =~ /="assets\/stylesheets\/master\.css"/
      assert html_content =~ /other\.css/
      assert !(html_content =~ /_a_css_partial\.css/)
    end
  end

  test "ignores epub.css in html" do
    in_temp_dir do
      wordsmith.init('w')
      assert File.exists?("w/assets/stylesheets/epub.css")

      Dir.chdir("w") { wordsmith.generate ["html"] }

      html_content = File.read("w/final/w/index.html")
      files = Dir.glob('w/final/**/*')

      assert !files.include?("w/final/w/assets/stylesheets/epub.css")
      assert !(html_content =~ /epub\.css/)
    end
  end

end
