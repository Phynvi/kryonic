plugin :test do 

  on_player_login(:equipment) do |player|
    player.io.send_sidebar_interfaces
  end

  on_command("reload") do |player, params|
    player.io.send_message "Reloading..." 
    SERVER.reload
  end

  on_command("update") do |player, params|
    time = params.first.to_i
    WORLD.submit_event Calyx::Tasks::SystemUpdateEvent.new(time)
  end

  on_int_button(3651) { |player| player.io.send_clear_screen }

  on_command("objspawn") do |player, params|
   temp_loc = player.location
    
   object = Calyx::Objects::Object.new(params[0].to_i, temp_loc, 2, params[1].to_i, -1, temp_loc, 0, params[2].to_i)
   object.change 
   
   # Add this to the object manager
   WORLD.object_manager.objects << object
  end

  on_command("pos") do |player, params|
    player.io.send_message "You are at #{player.location.inspect}."
  end

  on_command("goup") do |player, params|
    player.teleport_location = player.location.transform(0, 0, 1)  
  end

  on_command("godown") do |player, params|
    player.teleport_location = player.location.transform(0, 0, -1)  
  end

  on_command("item") do |player, params|
    id = params[0].to_i
    count = params.length == 2 ? params[1].to_i : 1
    player.inventory.add Calyx::Item::Item.new(id, count)
  end

  on_command("design") { |player, params| player.io.send_interface 3559 }

  on_command("spawn") do |player, params|
     id = params[0].to_i
     npc = Calyx::NPC::NPC.new Calyx::NPC::NPCDefinition.for_id(id)
     npc.location = player.location.transform(1, 1, 0)
     
     WORLD.register_npc npc
  end

  on_command("max") do |player, params|
    Calyx::Player::Skills::SKILLS.each do |skill|
      player.skills.set_skill skill, 99, 13034431
    end
    player.flags.flag :appearance
  end

  on_command("empty") do |player, params|
    player.inventory.clear
    player.inventory.fire_items_changed
  end

 on_command("tele") do |player, params|
    x = params[0].to_i
    y = params[1].to_i
    z = params.length > 2 ? params[2].to_i : 0
    loc = Calyx::Model::Location.new(x, y, z)
    player.io.send_message "Teleporting to #{loc.inspect}..."
    player.teleport_location = loc
  end

  on_command("teleto") do |player, params|
    target = get_player(params[0])
    unless target == nil
      player.teleport_location = target.location
      player.io.send_message "You were teleported to #{target.name}."
      target.io.send_message "#{player.name} teleported to you."
    else
      player.io.send_message "User not found."
    end
  end

  on_command("teletome") do |player, params|
    target = get_player(params[0])
    unless target == nil
      target.teleport_location = player.location
      player.io.send_message "#{target.name} was teleported to you."
      target.io.send_message "You were teleported to #{player.name}."
    else
      player.io.send_message "User not found."
    end
  end

  on_command("teleall") do |player, params|
    WORLD.players.each do |target|
      if target != nil and target.name != player.name
        target.teleport_location = player.location
        target.io.send_message "You were teleported to #{player.name}."
      end
    end
  end

  def get_player(name)
    WORLD.players.find { |e| e.name.downcase == name.downcase }
  end
end