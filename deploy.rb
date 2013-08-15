require 'date'
require 'erb'
require 'bundler'
require_relative 'runner'
require_relative 'log'

class Deploy
  attr_reader :env, :tag, :name, :id, :start, :log, :cmd

  class << self
    attr_accessor :runner, :keeper, :cmd

    def get(id)
      attrs = keeper.get(id)

      if attrs
        from_hash(attrs)
      else
        nil
      end
    end

    def get_all
      all = []
      keeper.get_all.each do |attrs|
        all << from_hash(attrs)
      end
      all
    end

    def from_hash(h)
      d = Deploy.new(h[:env], h[:tag], h[:name])
      start = h[:start]
      start = Time.at(start.to_i).to_datetime

      d.instance_variable_set('@id', h[:id])
      d.instance_variable_set('@start', start)
      d.log.instance_variable_set('@text', h[:log])
      d.instance_variable_set('@cmd', h[:cmd])
      d
    end
  end #self

  def initialize(env, tag, name)
    @env = env
    @tag = tag
    @name = name

    callback = lambda { |log|
      keeper.update_field(@id, :log, log)
    }
    @log = Log.new(callback)
  end

  def to_hash
    {
      :id => @id,
      :env => @env,
      :tag => @tag,
      :name => @name,
      :start => @start,
      :log => @log.read,
      :cmd => @cmd
    }
  end

  def save
    if @id.nil?
      @id = keeper.next_id
    end
    keeper.save(to_hash)
  end

  def gen_cmd
    ERB.new(self.class.cmd).result(binding)
  end

  def run
    @start = DateTime.now.strftime('%s').to_i
    @cmd = gen_cmd
    save
    Bundler.with_clean_env do
      runner.run(@cmd, @log)
    end
  end

  def runner
    self.class.runner
  end

  def keeper
    self.class.keeper
  end
end
