require File.expand_path "../test_helper", __FILE__

context "wordsmith init tests" do
  setup do
    @wordsmith = Wordsmith.new
  end

  test "can't init a wordsmith repo without a directory" do
    in_temp_dir do
      assert_raise RuntimeError do
        @wordsmith.init
      end
    end
  end

  test "can't init a wordsmith repo for existing dir" do
    in_temp_dir do
      Dir.mkdir('w')
      assert_raise RuntimeError do
        @wordsmith.init('w')
      end
    end
  end

  test "can init a wordsmith repo" do
    in_temp_dir do
      @wordsmith.init('w')
      files = Dir.glob('w/**/*', File::FNM_DOTMATCH)
      assert files.include? "w/README.md"
      assert files.include? "w/.wordsmith"
      assert files.include? "w/.gitignore"
    end
  end
end
