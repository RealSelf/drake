require 'spec_helper'

describe Deploy do 

  def fake_runner
    runner = double('Runner')
    runner.stub(:run) {nil}
    runner
  end

  def fake_redis
    redis = double('Redis')
  end
  
  before :each do
    @deploy = Deploy.new('production', 'master', 'sam')
    @deploy.runner = fake_runner
    @deploy.redis = fake_redis
  end

  describe "#log" do
    it "takes a line and saves it to this deploy's record in redis" do

    end
  end

  describe "#run!" do
    it "sets the id property to an integer" do
      @deploy.run!
      @deploy.id.should be_an_instance_of Fixnum
    end

    it "sets the start property to a recent unix timestamp" do
      @deploy.run!
      @deploy.start.should > 1373576439
    end

    it "calls Runner#run with self" do
      runner = fake_runner
      runner.should_receive(:run).with(@deploy)

      @deploy.runner = runner
      @deploy.run!
    end
  end

  describe "#cmd" do
    it "generates a shell command from instance variables" do
      @deploy.instance_eval{ cmd }.should eql "bundle exec cap chef deploy -e production -t master -n sam"
    end
  end

  describe "::new" do
    it "takes three parameters and returns a Deploy object" do
      @deploy.should be_an_instance_of Deploy
    end

    it "sets the environemnt" do
      @deploy.env.should eql 'production'
    end

    it "sets the tag" do
      @deploy.tag.should eql 'master'
    end

    it "sets the name" do
      @deploy.name.should eql 'sam'
    end
  end

end