require "wordsmith/cli"

describe Wordsmith::CLI do

  it "runs" do
    lambda{ Wordsmith.new.publish }.should_not raise_error
  end

  it "runs publish" do
    lambda{ Wordsmith.new.publish }.should_not raise_error
  end

end
