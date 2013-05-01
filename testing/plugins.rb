class Plugin

  attr_reader :name, :hooks

  def initialize(name)
    @name = name
    @hooks = AutoHash.new
  end

  def provides?(hook)
    @hooks.keys.include? hook
  end

  def on_a(id, &block)
    @hooks[:a][id] = block
  end

  def on_b
    nil
  end

  def on_c(a, b, c, &block)
    @hooks[:c][[a, b, c]] = block
  end

  def on_item_click(id, &block)
    @hooks[:item_click1][id] = block
  end
end

module PluginManager

  @plugins = {}

  def self.register_plugin(plugin)
    @plugins[plugin.name] = plugin

    puts "Registered plugin #{plugin.name}"
  end

  def self.run_hook(hook, params, block_args)
    plugins = @plugins.values.find_all { |plugin| plugin.provides?(hook) }

    plugins.each do |plugin|
      hook_block = plugin.hooks[hook][params]

      if hook_block.instance_of?(Proc)
        hook_block.call(*block_args)
      end
    end
  end
end

def plugin(name, &block)
  plugin = Plugin.new(name)
  plugin.instance_eval(&block)
  PluginManager.register_plugin(plugin)
end

plugin :something do
  # dummy plugin (no hooks defined)
end

plugin :magic_alchemy do

  on_b do |a, b|
    puts "do nothing"
  end

  on_a(1162) do |player, id, slot|
    puts "doing something"
  end

  on_c(10, 20, 30) do |player, x, y|
    puts "player: #{player}, x: #{x}, y: #{y}"
  end
end

plugin :horses do
  phrases = [
    "Come on Dobbin, we can win the race!",
    "Hi-ho Silver, and away!",
    "Neaahhhyyy! Giddy-up horsey!"
  ]

  (2520..2526).step(2) do |id|
    on_item_click(id) do |player, slot|
      puts phrases[rand(phrases.size)]
    end
  end
end

plugin :trade do
  def offer_item(player, slot, id, amount)
    puts "offering from #{player}"
    puts another
  end

  def another
    "bacon"
  end

  on_item_click(2520) do |player, slot|
    offer_item(player, slot, 1, 2)
  end
end

plugin :what do
  def offer_item(player, slot, id, amount)
    puts "offering222 from #{player}"
  end

  on_item_click(2520) do |player, slot|
    offer_item(player, slot, 1, 2)
  end
end

PluginManager.run_hook(:c, [10, 20, 30], ["jim", 2000, 3000])

PluginManager.run_hook(:item_click1, 2520, ["jim", 2])
