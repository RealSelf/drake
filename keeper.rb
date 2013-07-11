class Keeper
  BASE = 'deploy'

  def initialize(redis)
    @redis = redis
  end

  def log(id, line)
    @redis.append(key(id, 'log'), line)
  end

  def save(deploy)
    if deploy.id.nil? 
      deploy.id = next_id
    end
    deploy.to_hash.each do |k,v|
      @redis.set(key(deploy.id, k), v.to_s)  
    end
  end

  def next_id
    # Only sets the value if the key doesn't exist
    @redis.setnx(counter_key, 0)

    # Returns the value of the key after increment
    @redis.incr(counter_key)
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

end