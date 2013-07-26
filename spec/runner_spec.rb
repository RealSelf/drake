require 'spec_helper'

describe Runner do 

  def fake_open3
    double('Open3')
  end

  describe "#run" do
    it "takes a string command, an instance of Log and returns two threads" do
      log_line = 'a log line'
      stdin = double('IO')
      stdin.stub(:close) {nil}

      stdout = double('IO')
      stdout.stub(:close) {nil}
      stdout.stub(:gets) {log_line}

      stderr = double('IO')
      stderr.stub(:close) {nil}
      stderr.stub(:gets)

      cmd = 'cd /var/deploy; ./deploy.sh production master sam'
      log = double(Log)
      log.should_receive(:<<)

      wait_thr = double('Thread')

      open3 = fake_open3
      open3.stub(:popen3).and_return([stdin, stdout, stderr, wait_thr])
      open3.should_receive(:popen3).with(cmd)
      stub_const('Open3', open3)

      out_thr, err_thr = Runner.run(cmd, log)
      out_thr.join
      err_thr.join
    end

    it "calls log<< with a String" do

    end
  end

end