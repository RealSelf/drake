require 'date'
require_relative 'runner'

class Deploy
  class << self
    attr_accessor :runner, :keeper
  end

  attr_reader :env, :tag, :name, :id, :start

  def initialize(env, tag, name)
    @env = env
    @tag = tag
    @name = name
  end

  def to_hash
    {
      :id => @id,
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
    if @id.nil?
      @id = keeper.next_id
    end
    keeper.save(to_hash)
  end

  def log(line)
    keeper.log(@id, line)
  end

  def run!
    @id = 1
    @start = DateTime.now.strftime('%s').to_i

    runner.run(self)
  end

  def runner
    self.class.runner
  end  

  def keeper
    self.class.keeper
  end

end