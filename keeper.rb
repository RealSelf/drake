require 'date'

class Keeper
  class << self
    attr_accessor :redis
  end

  def initialize(namespace)
    @namespace = namespace
  end

  def get(id)
    hash = redis.hgetall(key(id))

    if hash.empty?
      hash = nil
    else
      hash.symbolize_keys!
    end
    hash
  end

  def get_all
    arr = []
    1.upto current_id do |id|
      arr << get(id)
    end
    arr
  end

  def update_field(id, field, val)
    redis.hset(key(id), field, val)
  end

  def save(hash)
    redis.hmset(key(hash[:id]), *hash.to_a.flatten)
  end

  def next_id
    # setnx only sets the value if the key doesn't exist
    redis.setnx(counter_key, 0)

    # Returns the value of the key after increment
    redis.incr(counter_key)
  end

  def current_id
    redis.get(counter_key).to_i
  end

  def counter_key
    "next.#{@namespace}.id"
  end

  def key(id)
    "#{@namespace}:#{id}"
  end

  private

  def redis
    self.class.redis
  end
end