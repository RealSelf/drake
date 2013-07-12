require 'spec_helper'

describe Keeper do 

  def fake_redis
    double('Redis')
  end
  
  before :each do
    Keeper.redis = fake_redis
    @keeper = Keeper.new
  end

  describe "#save" do
    it "takes a hash and saves it to Redis with one Redis field per hash key" do
      hash = {
        :id => Random.rand(5000),
        :env => 'production',
        :tag => 'master',
        :name => 'sam',
        :start => nil,
        :log => nil,
        :cmd => 'cd /var/deploy; ./deploy.sh production master sam'
      }

      Keeper.redis.should_receive(:set)
        .exactly(hash.length).times
        .with(kind_of(String), kind_of(String))
      
      @keeper.save(hash)
    end
  end

  describe "#next_id" do
    it "sets the counter value to 0 if the key doesn't exist" do
      Keeper.redis.stub(:incr) {1}

      Keeper.redis.should_receive(:incr).with(@keeper.counter_key)
      Keeper.redis.should_receive(:setnx).with(@keeper.counter_key, 0)

      @keeper.next_id.should eql 1
    end

    it "gets the next deploy id and increments the counter" do
      Keeper.redis.stub(:setnx) {0}
      Keeper.redis.stub(:incr) {2329}

      Keeper.redis.should_receive(:incr).with(@keeper.counter_key)

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
      Keeper.redis.should_receive(:append).with(key, log_line)

      @keeper.log(deploy_id, log_line)
    end
  end

end