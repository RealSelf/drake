class Keeper
  BASE = 'deploy'

  class << self
    attr_accessor :redis
  end

  def log(id, line)
    redis.append(key(id, 'log'), line)
  end

  def save(hash)
    hash.each do |k,v|
      redis.set(key(hash[:id], k), v.to_s)  
    end
  end

  def next_id
    # Only sets the value if the key doesn't exist
    redis.setnx(counter_key, 0)

    # Returns the value of the key after increment
    redis.incr(counter_key)
  end

  def counter_key
    "next.#{Keeper::BASE}.id"
  end

  def key(id, attribute=nil)
    str = "#{Keeper::BASE}:#{id}"
    unless attribute.nil?
      str << ":#{attribute}"
    end
    str
  end

  private

  def redis
    self.class.redis
  end

end