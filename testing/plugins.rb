module InputHooks

  # Controls
  def on_mouse_click(trigger = :default, &block)
    HOOKS[:mouse_click][trigger] = block
  end

  def on_camera_move(trigger = :default, &block)
    HOOKS[:camera_move][trigger] = block
  end

  # Chat
  def on_chat(trigger = :default, &block)
    HOOKS[:chat][trigger] = block
  end

  def on_command(name, rights = :player, &block)
    HOOKS[:command][name] = lambda {|player, params|
      if Calyx::World::RIGHTS.index(player.rights) >= Calyx::World::RIGHTS.index(rights)
        block.call(player, params)
      end
    }
  end
end

module InterfaceHooks
  
  def on_int_button(id, &block)
    HOOKS[:int_button][id] = block
  end

  def on_int_enter_amount(id, &block)
    HOOKS[:int_enteramount][id] = block
  end

  def on_int_close(id, &block)
    HOOKS[:int_close][id] = block
  end

  def set_int_size(id, size)
    HOOKS[:int_size][id] = size
  end
end

module ItemHooks

  def on_item_click(id, &block)
    HOOKS[:item_click1][id] = block
  end

  def on_item_click2(id, &block)
    HOOKS[:item_click2][id] = block
  end

  def on_item_drop(id, &block)
    HOOKS[:item_drop][id] = block
  end

  def on_item_wield(interface_id, &block)
    HOOKS[:item_wield][interface_id] = block
  end

  def on_item_option(id, &block)
    HOOKS[:item_option1][id] = block
  end

  def on_item_option2(id, &block)
    HOOKS[:item_option2][id] = block
  end

  def on_item_option3(id, &block)
    HOOKS[:item_option3][id] = block
  end

  def on_item_option4(id, &block)
    HOOKS[:item_option4][id] = block
  end

  def on_item_option5(id, &block)
    HOOKS[:item_option5][id] = block
  end

  def on_item_alt2(id, &block)
    HOOKS[:item_alt2][id] = block
  end

  def on_item_on_ground(id, &block)
    HOOKS[:item_on_ground][id] = block
  end

  def on_item_swap(interface_id, &block)
    HOOKS[:item_swap][interface_id] = block
  end

  def on_item_on_item(first_id, second_id, &block)
    HOOKS[:item_on_item][[first_id, second_id].sort] = block
  end

  def on_item_on_floor(inv_id, floor_id, &block)
    HOOKS[:item_on_floor][[inv_id, floor_id]] = block
  end

  def on_item_on_obj(item_id, object_id, &block)
    HOOKS[:item_on_obj][[item_id, object_id]] = block
  end

  def on_item_on_player(id, &block)
    HOOKS[:item_on_player][id] = block
  end

  def on_item_on_npc(id, npc_id, &block)
    HOOKS[:item_on_npc][[id, npc_id]] = block
  end
end

module ObjectHooks

  def on_obj_option(id, &block)
    HOOKS[:obj_click1][id] = block
  end

  def on_obj_option2(id, &block)
    HOOKS[:obj_click2][id] = block
  end

  def on_obj_option3(id, &block)
    HOOKS[:obj_click3][id] = block
  end
end

module PlayerHooks

  def on_player_trade(id, &block)
    HOOKS[:trade_option][id] = block
  end

  def on_player_login(trigger = :default, &block)
    HOOKS[:player_login][trigger] = block
  end

  def on_player_logout(trigger = :default, &block)
    HOOKS[:player_logout][trigger] = block
  end
end

module MagicHooks

  def on_magic_on_item(spell_id, &block)
    HOOKS[:magic_on_item][spell_id] = block
  end

  def on_magic_on_floor(item_id, spell_id, &block)
    HOOKS[:magic_on_flooritem][[item_id, spell_id]] = block
  end

  def on_magic_on_npc(spell_id, &block)
    HOOKS[:magic_on_npc][spell_id] = block
  end

  def on_magic_on_player(spell_id, &block)
    HOOKS[:magic_on_player][spell_id] = block
  end
end

module NpcHooks

  def on_npc_option(id, &block)
    HOOKS[:npc_option1][id] = block
  end

  def on_npc_option2(id, &block)
    HOOKS[:npc_option2][id] = block
  end

  def on_npc_option3(id, &block)
    HOOKS[:npc_option3][id] = block
  end

  def on_npc_attack(id, &block)
    HOOKS[:npc_attack][id] = block
  end
end

class AutoHash < Hash
  def initialize(*args)
    super()
    @update, @update_index = args[0][:update], args[0][:update_key] unless args.empty?
  end

  def [](k)
    if self.has_key?k
      super(k)
    else
      AutoHash.new(:update => self, :update_key => k)
    end
  end

  def []=(k, v)
    @update[@update_index] = self if @update and @update_index
    super
  end
end

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
