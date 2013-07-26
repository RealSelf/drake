require 'spec_helper'

describe Log do

  describe "::new" do
    it "takes a callback and returns an instance of Log" do
      Log.new(lambda { |line| }).should be_an_instance_of Log
    end
  end

  describe "#<<" do
    it "takes a line and concatenates it to it's text" do
      log = Log.new(lambda { |line| })
      line = 'first line!'
      log << line
      log.instance_eval{ @text }.should eql line
    end

    it "calls the callback with the full text" do
      line = 'new line!'
      callback = double(Proc)
      log = Log.new(callback)

      log.instance_variable_set('@text', 'fist line')
      callback.should_receive(:call).with(log.instance_eval{ @text })
      log << line
    end
  end

  describe "#read" do
    it "returns the full text of the log" do

    end
  end
end