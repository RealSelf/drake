require 'open3'

class Runner
  def run(deploy)
    stdin, stdout, stderr, wait_thr = Open3.popen3("echo #{deploy.cmd} | sh")

    # Must close all IO streams explicitly
    stdin.close  

    Thread.new do
      out_thr = Thread.new do
        Thread.current.abort_on_exception = true
        while(line = stdout.gets)
          deploy.log(line)
        end
        stdout.close
      end

      err_thr = Thread.new do
        Thread.current.abort_on_exception = true
        while(line = stderr.gets)
          deploy.log(line)
        end
        stderr.close
      end
    end
  end
end
