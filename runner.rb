require 'open3'

class Runner
  def run(cmd, log)
    stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)

    # Must close all IO streams explicitly
    stdin.close

    out_thr = Thread.new do
      Thread.current.abort_on_exception = true
      while(line = stdout.gets)
        log << line
      end
      stdout.close
    end

    err_thr = Thread.new do
      Thread.current.abort_on_exception = true
      while(line = stderr.gets)
        log << line
      end
      stderr.close
    end

    return out_thr, err_thr
  end
end
