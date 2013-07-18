require 'date'
require_relative 'runner'

class Deploy
  class << self
    attr_accessor :runner, :keeper

    def get(id)
      keeper.get(id)
    end

    def from_hash(h)
      d = self.allocate
      h.each do |k,v|
        d.instance_variable_set("@#{k}", v)
      end
      d
    end

    def attrs
      [:id, :env, :tag, :name, :start, :log, :cmd]
    end
  end

  attr_reader :env, :tag, :name, :id, :start, :log, :cmd

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
      :cmd => @cmd
    }
  end

  def save
    if @id.nil?
      @id = keeper.next_id
    end
    keeper.save(to_hash)
  end

  def log_line(line)
    keeper.log(@id, line)
  end

  def log
    @log
  end

  def gen_cmd
    "cd ~/code/Stock; bundle exec cap chef deploy -s chef_environment=#{@env} -s tag=#{@tag} -s deployed_by=#{@name}"
  end

  def run!
    @start = DateTime.now.strftime('%s').to_i
    @cmd = gen_cmd
    save
    runner.run(self)
  end

  def runner
    self.class.runner
  end  

  def keeper
    self.class.keeper
  end

end