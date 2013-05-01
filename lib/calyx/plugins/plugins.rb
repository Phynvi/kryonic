require 'calyx/plugins/hooks'

module Calyx::Plugins

  @plugins = {}

  def self.register(plugin)
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

  def self.run_loader(plugin)
    plugin = @plugins[plugin]

    plugin.hooks[:plugin_load].each do |hook|
      puts "Running loader hook!"

      hook.call
    end
  end

  def self.get(plugin)
    @plugins[plugin]
  end

  class Plugin

    include SupportHooks
    include InputHooks
    include InterfaceHooks
    include ItemHooks
    include ObjectHooks
    include PlayerHooks
    include MagicHooks
    include NpcHooks

    attr_reader :name, :hooks

    def initialize(name)
      @name = name
      @hooks = Calyx::Misc::AutoHash.new
    end

    def provides?(hook)
      @hooks.keys.include? hook
    end
  end
end

def plugin(name, &block)
  plugin = Calyx::Plugins::Plugin.new(name)
  plugin.instance_eval(&block)
  Calyx::Plugins.register(plugin)
end

HOOKS = Hash.new { {} }