require 'spec_helper'

describe Keeper do 

  def fake_redis
    double('Redis')
  end

  def namespace
    :test
  end

  def example_hash
    {
      :id => Random.rand(5000),
      :env => 'test',
      :tag => 'v2.5.1999',
      :name => 'sam',
      :start => nil,
      :log => nil,
      :cmd => 'cd /var/deploy; ./deploy.sh test master sam'
    }
  end

  before :each do
    Keeper.redis = fake_redis
    @keeper = Keeper.new(namespace)
  end

  describe "::new" do
    it "takes a symbol and sets @namespace to that symbol" do
      @keeper.instance_eval{ @namespace }.should eql :test
    end
  end

  describe "::get" do
    it "takes an ID and returns a hash" do
      hash = example_hash
      id = hash[:id]
      Keeper.redis.should_receive(:hgetall).with(match(/#{id}/)) { hash }

      @keeper.get(id).should eql hash
    end
  end

  describe "::get_all" do
    #todo
  end

  describe "#update_field" do
    it "takes and ID, field, and value and sets them in redis" do
      id = Random.rand(5000)
      field = :name
      val = 'Sam'
      Keeper.redis.should_receive(:hset).with(match(/#{id}/), field, val)

      @keeper.update_field(id, field, val)
    end
  end

  describe "#save" do
    it "takes a hash and saves it to Redis as a hash" do
      attrs = example_hash

      Keeper.redis.should_receive(:hmset) do |arg1,  *args|
        arg1.should be_an_instance_of(String)
        arg1.should_not be_empty
        args.length.should eql attrs.to_a.flatten.length
      end
      @keeper.save(attrs)
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

  describe "#current_id" do
    it "returns the current ID" do
      id = Random.rand(5000)
      Keeper.redis.should_receive(:get) { id }
      @keeper.current_id.should eql id
    end
  end

  describe "#key" do
    it "takes an ID and returns a string Redis key with the namespace" do
      id = Random.rand(5000)
      @keeper.key(id).should eql "#{namespace}:#{id}"
    end
  end



end