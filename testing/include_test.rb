module ItemHooks

  def on_item_a
    @hooks[:item_a] = "hey"
  end
end

class Plugin

  include ItemHooks

  def initialize
    @hooks = {}
  end

  def on_builtin
    @hooks[:builtin] = "hello"
  end

  attr_reader :hooks
end



plugin = Plugin.new

plugin.on_builtin
plugin.on_item_a

puts plugin.hooks.inspect