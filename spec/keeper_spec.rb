require 'spec_helper'

describe Keeper do 

  def fake_redis
    redis = double('Redis')
  end
  
  before :each do
    @redis = fake_redis
    @keeper = Keeper.new(@redis)
  end

  describe "#new" do
    it "takes a redis instance as a paramater and sets it as a instance variable" do
      @keeper.instance_eval{ @redis }.should eql @redis
    end
  end


  describe "#next_id" do
    it "sets the counter value to 0 if the key doesn't exist" do
      @redis.stub(:incr) {1}

      @redis.should_receive(:incr).with(@keeper.counter_key)
      @redis.should_receive(:setnx).with(@keeper.counter_key, 0)

      @keeper.next_id.should eql 1
    end

    it "gets the next deploy id and increments the counter" do
      @redis.stub(:setnx) {0}
      @redis.stub(:incr) {2329}

      @redis.should_receive(:incr).with(@keeper.counter_key)

      @keeper.next_id.should eql 2329
    end
  end

  describe "#key" do
    it "takes an id a string Redis key" do
      @keeper.key(89238).should eql "deploy:89238"
    end

    it "takes an id and an attribute and returns a string Redis key" do
      @keeper.key(10099, 'status').should eql "deploy:10099:status"
    end
  end

  describe "#log" do
    it "appends a line to the log field of a deploy record in Redis" do
      deploy_id = 533
      log_line = "[you are a god] Everything went totally awesome\n"

      key = @keeper.key(deploy_id, 'log')
      @redis.should_receive(:append).with(key, log_line)

      @keeper.log(deploy_id, log_line)
    end
  end

end