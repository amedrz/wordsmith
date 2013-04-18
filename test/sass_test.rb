require File.expand_path "../test_helper", __FILE__

context "wordsmith sass tests" do

  def wordsmith
    Wordsmith.new
  end

  test "compiles stylesheets directory" do
    in_temp_dir do
      wordsmith.init('w')
      File.rename("w/assets/stylesheets/default.css",
        "w/assets/stylesheets/default.scss")
      Dir.chdir("w") { wordsmith.generate ["html"] }
      files = Dir.glob('w/**/*')
      assert files.include? "w/final/w/assets/stylesheets/default.css"
    end
  end

  test "copies css files" do
    in_temp_dir do
      wordsmith.init('w')
      Dir.chdir("w") { wordsmith.generate ["html"] }
      files = Dir.glob('w/**/*')
      assert files.include? "w/final/w/assets/stylesheets/default.css"
    end
  end
end
