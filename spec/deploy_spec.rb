require 'spec_helper'

describe Deploy do 

  def fake_runner
    runner = double('Runner')
    runner.stub(:run) {nil}
    runner
  end

  def fake_keeper
    double('Keeper')
  end
  
  before :each do
    Deploy.runner = fake_runner
    Deploy.keeper = fake_keeper

    Deploy.keeper.stub(:next_id) {Random.rand(5000)}
    Deploy.keeper.stub(:save)

    @deploy = Deploy.new('production', 'master', 'sam')
  end

  describe "::from_hash" do
    it "takes a hash and returns an instance of Deploy with instance variables matching the hash" do
      hash = {
        :id => Random.rand(5000),
        :env => 'production',
        :tag => 'master',
        :name => 'sam',
        :start => nil,
        :log => nil,
        :cmd => 'cd /var/deploy; ./deploy.sh production master sam'
      }
      d = Deploy.from_hash(hash)

      d.instance_eval{ @id }.should eql hash[:id]
      d.instance_eval{ @env }.should eql hash[:env]
      d.instance_eval{ @tag }.should eql hash[:tag]
      d.instance_eval{ @name }.should eql hash[:name]
      d.instance_eval{ @start }.should eql hash[:start]
      d.instance_eval{ @log }.should eql hash[:log]
      d.instance_eval{ @cmd }.should eql hash[:cmd]
    end
  end

  describe "::new" do
    it "takes three parameters and returns a Deploy object" do
      @deploy.should be_an_instance_of Deploy
    end

    it "sets the environment" do
      @deploy.env.should eql 'production'
    end

    it "sets the tag" do
      @deploy.tag.should eql 'master'
    end

    it "sets the name" do
      @deploy.name.should eql 'sam'
    end
  end

  describe "#save" do
    it "calls Deploy.keeper.save with a hash of this instance's attributes" do
      id = Random.rand(5000)
      Deploy.keeper.stub(:next_id) { id }

      deploy_hash = @deploy.to_hash
      deploy_hash[:id] = id
      Deploy.keeper.should_receive(:save).with(deploy_hash)

      @deploy.save
    end

    it "calls Deploy.keeper.next_id to set its id attribute" do
      id = Random.rand(5000)
      Deploy.keeper.stub(:next_id) { id }
      Deploy.keeper.should_receive(:next_id)

      @deploy.save
      @deploy.id.should eql id
    end
  end

  describe "#log_line" do
    it "takes a line and calls Deploy.keeper.log with this Deploy's id and the line" do
      line = "[BRNG] Something very mundane happened"
      id = Random.rand(5000)
      
      @deploy.instance_variable_set(:@id, id)
      Deploy.keeper.should_receive(:log).with(@deploy.id, line)

      @deploy.log_line(line)
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

    it "calls Deploy.runner.run with self" do
      Deploy.runner.should_receive(:run).with(@deploy)
      @deploy.run!
    end
  end

  describe "#cmd" do
    it "generates a shell command from instance variables" do
      @deploy.instance_eval{ cmd }.should eql "bundle exec cap chef deploy -e production -t master -n sam"
    end
  end

end