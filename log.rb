class Log
  def initialize(callback)
    @callback = callback
    @text = ''
  end

  def << str
    @text << str
    @callback.call(@text)
  end

  def read
    @text
  end
end