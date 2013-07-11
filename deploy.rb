require 'date'
require_relative 'runner'

class Deploy
  REDIS_BRANCH = 'deploy'

  attr_reader :env, :tag, :name, :id, :start
  attr_writer :runner, :redis

  def initialize(env, tag, name)
    @env = env
    @tag = tag
    @name = name
  end

  def to_hash
    {
      :env => @env,
      :tag => @tag,
      :name => @name,
      :start => @start,
      :log => @log,
      :cmd => cmd
    }
  end

  def cmd
    "bundle exec cap chef deploy -e #{@env} -t #{@tag} -n #{@name}"
  end

  def save
    @keeper.save(self)
  end

  def log(line)
    @keeper.log(@id, line)
  end

  def run!
    @id = 1
    @start = DateTime.now.strftime('%s').to_i

    @runner.run(self)
  end

end