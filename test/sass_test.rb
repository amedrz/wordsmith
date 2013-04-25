require File.expand_path "../test_helper", __FILE__

context "wordsmith sass tests" do

  def wordsmith
    Wordsmith.new
  end

  test "compiles stylesheets directory" do
    in_temp_dir do
      wordsmith.init('w')
      File.rename("w/assets/stylesheets/_with_sass.scss",
        "w/assets/stylesheets/with_sass.scss")
      Dir.chdir("w") { wordsmith.generate ["html"] }
      files = Dir.glob('w/**/*')
      assert files.include? "w/final/w/assets/stylesheets/master.css"
    end
  end

end
