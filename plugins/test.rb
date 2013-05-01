on_command("objspawn") {|player, params|
 temp_loc = player.location
  
 object = Calyx::Objects::Object.new(params[0].to_i, temp_loc, 2, params[1].to_i, -1, temp_loc, 0, params[2].to_i)
 object.change 
 
 # Add this to the object manager
 WORLD.object_manager.objects << object
}

on_command("pos") {|player, params|
  player.io.send_message "You are at #{player.location.inspect}."
}

on_command("update") {|player, params|
  time = params.first.to_i
  WORLD.submit_event Calyx::Tasks::SystemUpdateEvent.new(time)
}

on_command("goup") {|player, params|
  player.teleport_location = player.location.transform(0, 0, 1)  
}

on_command("godown") {|player, params|
  player.teleport_location = player.location.transform(0, 0, -1)  
}

on_command("item") {|player, params|
  id = params[0].to_i
  count = params.length == 2 ? params[1].to_i : 1
  player.inventory.add Calyx::Item::Item.new(id, count)
}

on_command("design") {|player, params|
  player.io.send_interface 3559
}

on_int_button(3651) {|player|
  player.io.send_clear_screen
}

on_command("reload") {|player, params|
  player.io.send_message "Reloading..." 
  SERVER.reload
}

on_command("spawn") {|player, params|
   id = params[0].to_i
   npc = Calyx::NPC::NPC.new Calyx::NPC::NPCDefinition.for_id(id)
   npc.location = player.location.transform(1, 1, 0)
   
   WORLD.register_npc npc
}

on_command("teleto") {|player, params|
  target = get_player(params[0])
  unless target == nil
    player.teleport_location = target.location
    player.io.send_message "You were teleported to #{target.name}."
    target.io.send_message "#{player.name} teleported to you."
  else
    player.io.send_message "User not found."
  end
}

on_command("tele") {|player, params|
  x = params[0].to_i
  y = params[1].to_i
  z = params.length > 2 ? params[2].to_i : 0
  loc = Calyx::Model::Location.new(x, y, z)
  player.io.send_message "Teleporting to #{loc.inspect}..."
  player.teleport_location = loc
}

on_command("teletome") {|player, params|
  target = get_player(params[0])
  unless target == nil
    target.teleport_location = player.location
    player.io.send_message "#{target.name} was teleported to you."
    target.io.send_message "You were teleported to #{player.name}."
  else
    player.io.send_message "User not found."
  end
}

on_command("teleall") {|player, params|
  WORLD.players.each {|target|
    if target != nil and target.name != player.name
      target.teleport_location = player.location
      target.io.send_message "You were teleported to #{player.name}."
    end
  }
}

on_command("g") {|player, params|
  x = player.location.x + 1
  y = player.location.y
  z = player.location.z
  
  player.face Calyx::Model::Location.new(x, y, z)
}

on_command("max") {|player, params|
  Calyx::Player::Skills::SKILLS.each {|skill|
    player.skills.set_skill skill, 99, 13034431
  }
  player.flags.flag :appearance
}

on_command("empty") {|player, params|
  player.inventory.clear
  player.inventory.fire_items_changed
}

def self.get_player(name)
  WORLD.players.find {|e| e.name.downcase == name.downcase }
end