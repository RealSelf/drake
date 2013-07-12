require 'spec_helper'

describe Runner do 

  def fake_open3
    double('Open3')
  end

  before :each do
    @runner = Runner.new
  end

  describe "#run" do
    it "takes a Deploy instance and runs deploy@cmd, logging to deploy#log" do
      stdin = double('IO')
      stdin.stub(:close) {nil}

      stdout = double('IO')
      stdout.stub(:close) {nil}
      stdout.stub(:gets)

      stderr = double('IO')
      stderr.stub(:close) {nil}
      stderr.stub(:gets)

      deploy = double('Deploy')
      deploy.stub(:cmd) {'cd /var/deploy; ./deploy.sh production master sam'}
      deploy.should_receive(:cmd)

      wait_thr = double('Thread')

      open3 = fake_open3
      open3.stub(:popen3).and_return([stdin, stdout, stderr, wait_thr])
      open3.should_receive(:popen3).with(match(/cd \/var\/deploy; .\/deploy.sh production master sam/))
      stub_const('Open3', open3)

      out_thr, err_thr = @runner.run(deploy)
      out_thr.join
      err_thr.join
    end
  end

end