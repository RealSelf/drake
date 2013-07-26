require 'spec_helper'

describe Deploy do 

  def fake_runner
    runner = double('Runner')
    runner.stub(:run) {nil}
    runner
  end

  def fake_keeper
    keeper = double('Keeper')
    keeper.stub(:next_id) {Random.rand(5000)}
    keeper.stub(:save)
    keeper.stub(:update_field)
    keeper
  end

  def deploy_hash
    {
       :id => Random.rand(5000),
       :env => 'production',
       :tag => 'master',
       :name => 'sam',
       :start => nil,
       :log => nil,
       :cmd => 'cd /var/deploy; ./deploy.sh production master sam'
     }
  end
  
  before :each do
    Deploy.runner = fake_runner
    Deploy.keeper = fake_keeper

    @deploy = Deploy.new('production', 'master', 'sam')
  end

  describe "::from_hash" do
    it "takes a hash and returns an instance of Deploy with instance variables matching the hash" do
      hash = deploy_hash
      d = Deploy.from_hash(hash)

      d.instance_eval{ @id }.should eql hash[:id]
      d.instance_eval{ @env }.should eql hash[:env]
      d.instance_eval{ @tag }.should eql hash[:tag]
      d.instance_eval{ @name }.should eql hash[:name]
      d.instance_eval{ @start }.should be_an_instance_of(DateTime)
      d.instance_eval{ @log }.should be_an_instance_of(Log)
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

    it "sets @name" do
      @deploy.name.should eql 'sam'
    end

    it "sets the log to an instance of Log" do
      @deploy.log.should be_an_instance_of Log
    end
  end

  describe "::get" do
    it "takes an id and returns an instance of Deploy" do
      hash = deploy_hash
      Deploy.keeper.should_receive(:get).with(hash[:id]) { hash }
      Deploy.get(hash[:id]).should be_instance_of Deploy
    end
  end

  describe "#to_hash" do
    it "returns a hash of a Deploy instance's attributes" do
      hash = @deploy.to_hash

      hash[:id].should eql @deploy.instance_eval{ @id }
      hash[:env].should eql @deploy.instance_eval{ @env }
      hash[:tag].should eql @deploy.instance_eval{ @tag }
      hash[:name].should eql @deploy.instance_eval{ @name }
      hash[:cmd].should eql @deploy.instance_eval{ @cmd }
      hash[:start].should eql @deploy.instance_eval{ @stat }
      hash[:log].should eql @deploy.instance_eval{ @log.read }
    end

    it "sets :log to the value of @log.read instead of a Log object" do
      @deploy.log << 'a new line'
      @deploy.log << 'an even newer line'
      hash = @deploy.to_hash

      hash[:log].should eql @deploy.log.read
      hash[:log].should_not be_an_instance_of Log
    end
  end

  describe "#save" do
    it "calls Deploy.keeper.save with a hash of this instance's attributes" do
      id = Random.rand(5000)
      Deploy.keeper.stub(:next_id) { id }

      hash = @deploy.to_hash
      hash[:id] = id
      Deploy.keeper.should_receive(:save).with(hash)

      @deploy.save
    end

    it "sets the id" do
      id = Random.rand(5000)
      Deploy.keeper.stub(:next_id) { id }
      Deploy.keeper.should_receive(:next_id).with(no_args)

      @deploy.save
      @deploy.id.should eql id
    end
  end

  describe "#run" do
    it "sets the id property" do
      @deploy.run
      @deploy.id.should be_an_instance_of Fixnum
    end

    it "sets the start property to a recent unix timestamp" do
      @deploy.run
      @deploy.start.should > DateTime.now.strftime('%s').to_i - 300
    end

    it "calls save" do
      @deploy.should_receive(:save).with(no_args)
      @deploy.run
    end

    it "calls runner.run with a string and a Log" do
      @deploy.stub(:runner) { Deploy.runner }
      Deploy.runner.should_receive(:run).with(an_instance_of(String), an_instance_of(Log))
      Deploy.runner.should_not_receive(:run).with('', an_instance_of(Log))
      @deploy.run
    end
  end

  describe "#gen_cmd" do
    it "generates a shell command from instance variables" do
      @deploy.instance_eval{ gen_cmd }.should be_an_instance_of(String)
      @deploy.instance_eval{ gen_cmd }.should_not eql ''
    end
  end
end