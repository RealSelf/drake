require 'open3'

class Runner
  def run(deploy)
    stdin, stdout, stderr, wait_thr = Open3.popen3(deploy.cmd.strip)

    # Must close all IO streams explicitly
    stdin.close  

    out_thr = Thread.new do
      Thread.current.abort_on_exception = true
      while(line = stdout.gets)
        deploy.log_line(line)
      end
      stdout.close
    end

    err_thr = Thread.new do
      Thread.current.abort_on_exception = true
      while(line = stderr.gets)
        deploy.log_line(line)
      end
      stderr.close
    end

    return out_thr, err_thr
  end
end
