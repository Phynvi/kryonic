module Calyx::Plugins

  module SupportHooks
    def on_load(&block)
      unless @hooks[:plugin_load].instance_of?(Array)
        @hooks[:plugin_load] = []
      end

      @hooks[:plugin_load] << block
    end

    def load_yaml(file)
      # TODO secure this
      YAML.load_file("./plugin_rewrite/#{@name}/#{file}")
    end
  end

  module InputHooks

    # Controls
    def on_mouse_click(trigger = :default, &block)
      @hooks[:mouse_click][trigger] = block
    end

    def on_camera_move(trigger = :default, &block)
      @hooks[:camera_move][trigger] = block
    end

    # Chat
    def on_chat(trigger = :default, &block)
      @hooks[:chat][trigger] = block
    end

    def on_command(name, rights = :player, &block)
      @hooks[:command][name] = lambda {|player, params|
        if Calyx::World::RIGHTS.index(player.rights) >= Calyx::World::RIGHTS.index(rights)
          block.call(player, params)
        end
      }
    end
  end

  module InterfaceHooks
    
    def on_int_button(id, &block)
      @hooks[:int_button][id] = block
    end

    def on_int_enter_amount(id, &block)
      @hooks[:int_enteramount][id] = block
    end

    def on_int_close(id, &block)
      @hooks[:int_close][id] = block
    end

    def set_int_size(id, size)
      @hooks[:int_size][id] = size
    end
  end

  module ItemHooks

    def on_item_click(id, &block)
      @hooks[:item_click1][id] = block
    end

    def on_item_click2(id, &block)
      @hooks[:item_click2][id] = block
    end

    def on_item_drop(id, &block)
      @hooks[:item_drop][id] = block
    end

    def on_item_wield(interface_id, &block)
      @hooks[:item_wield][interface_id] = block
    end

    def on_item_option(id, &block)
      @hooks[:item_option1][id] = block
    end

    def on_item_option2(id, &block)
      @hooks[:item_option2][id] = block
    end

    def on_item_option3(id, &block)
      @hooks[:item_option3][id] = block
    end

    def on_item_option4(id, &block)
      @hooks[:item_option4][id] = block
    end

    def on_item_option5(id, &block)
      @hooks[:item_option5][id] = block
    end

    def on_item_alt2(id, &block)
      @hooks[:item_alt2][id] = block
    end

    def on_item_on_ground(id, &block)
      @hooks[:item_on_ground][id] = block
    end

    def on_item_swap(interface_id, &block)
      @hooks[:item_swap][interface_id] = block
    end

    def on_item_on_item(first_id, second_id, &block)
      @hooks[:item_on_item][[first_id, second_id].sort] = block
    end

    def on_item_on_floor(inv_id, floor_id, &block)
      @hooks[:item_on_floor][[inv_id, floor_id]] = block
    end

    def on_item_on_obj(item_id, object_id, &block)
      @hooks[:item_on_obj][[item_id, object_id]] = block
    end

    def on_item_on_player(id, &block)
      @hooks[:item_on_player][id] = block
    end

    def on_item_on_npc(id, npc_id, &block)
      @hooks[:item_on_npc][[id, npc_id]] = block
    end
  end

  module ObjectHooks

    def on_obj_option(id, &block)
      @hooks[:obj_click1][id] = block
    end

    def on_obj_option2(id, &block)
      @hooks[:obj_click2][id] = block
    end

    def on_obj_option3(id, &block)
      @hooks[:obj_click3][id] = block
    end
  end

  module PlayerHooks

    def on_player_trade(id, &block)
      @hooks[:trade_option][id] = block
    end

    def on_player_login(trigger = :default, &block)
      @hooks[:player_login][trigger] = block
    end

    def on_player_logout(trigger = :default, &block)
      @hooks[:player_logout][trigger] = block
    end
  end

  module MagicHooks

    def on_magic_on_item(spell_id, &block)
      @hooks[:magic_on_item][spell_id] = block
    end

    def on_magic_on_floor(item_id, spell_id, &block)
      @hooks[:magic_on_flooritem][[item_id, spell_id]] = block
    end

    def on_magic_on_npc(spell_id, &block)
      @hooks[:magic_on_npc][spell_id] = block
    end

    def on_magic_on_player(spell_id, &block)
      @hooks[:magic_on_player][spell_id] = block
    end
  end

  module NpcHooks

    def on_npc_option(id, &block)
      @hooks[:npc_option1][id] = block
    end

    def on_npc_option2(id, &block)
      @hooks[:npc_option2][id] = block
    end

    def on_npc_option3(id, &block)
      @hooks[:npc_option3][id] = block
    end

    def on_npc_attack(id, &block)
      @hooks[:npc_attack][id] = block
    end
  end
end