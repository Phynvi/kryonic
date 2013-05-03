require 'calyx/plugins/hooks'

module Calyx::Plugins

  LOG = Logging.logger['plugin']

  @plugins = {}

  def self.register(plugin)
    unless @plugins.has_key?(plugin.name)
      @plugins[plugin.name] = plugin
    end
  end

  def self.run_one(hook, params, block_args)
    plugins = @plugins.values.find_all { |plugin| plugin.provides?(hook) }

    plugins.each do |plugin|
      block = plugin.hooks[hook][params]

      if block.instance_of?(Proc)
        block.call(*block_args)
        return true
      end
    end

    return false
  end

  def self.run_hook(hook, params, block_args)
    plugins = @plugins.values.find_all { |plugin| plugin.provides?(hook) }

    plugins.each do |plugin|
      stack = []

      if params
        block = plugin.hooks[hook][params]
        stack.push(block) if block.instance_of?(Proc)
      else
        plugin.hooks[hook].each { |trigger, block| stack.push(block) }
      end

      stack.each do |block|
        if block_given?
          yield(block, block_args)
        else
          block.call(*block_args)
        end
      end
    end
  end

  def self.load_all
    LOG.info "Starting plugin load"

    # Load each script
    Dir['./plugin_rewrite/*/'].each do |folder|
      name = File.basename(folder).to_sym

      LOG.info "Found plugin: #{name}"

      scripts = Dir[File.join(folder, "*.rb")]

      scripts.each do |script|
        LOG.debug "  #{File.basename(script)}"
        load script
      end
    end

    # Run all loaders
    @plugins.values.each do |plugin|
      plugin.hooks[:plugin_load].each do |hook|
        LOG.debug "[#{plugin.name}] running on_load ..."
        hook.call
      end
    end
  end

=begin
  load "./plugin_rewrite/woodcutting/woodcutting.rb"

  #plugin = Calyx::Plugins.get(:woodcutting)

  #Calyx::Plugins.run_loader(:woodcutting)
=end

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
  plugin = Calyx::Plugins.get(name)

  unless plugin
    plugin = Calyx::Plugins::Plugin.new(name)
  end

  plugin.instance_eval(&block)

  Calyx::Plugins.register(plugin)
end

HOOKS = Hash.new { {} }