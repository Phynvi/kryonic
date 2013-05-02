plugin :equipment do

  on_load do
    # Load sidebar data
    @sidebars = load_yaml("sidebars.yaml")
    @sidebars.each do |row|
      row[:regex] = row[:regex].to_regexp
      row[:type]  = row[:type].to_sym
    end

    # Load slot data
    @slots = load_yaml("slots.yaml")

    # Load exception data
    @exceptions = load_yaml("exceptions.yaml")
  end

  def slot(name)
    name = name.downcase

    slot = @slots.find do |e| 
      e[:names].find do |s|
        name.include?(s)
      end
    end

    (slot && slot[:slot]) || 3
  end

  def is(item, type)
    name = item.definition.name.downcase
    slot = @slots.find {|e| e[:check] == type }
    slot[:names].find {|s| name.include?(s) } != nil
  end

  def get_exception(id)
    item = @exceptions.find {|e| e[:id] == id }
    item && item[:slot]
  end

  def equip(player, item, slot, name, id)
    if item != nil && item.id == id
      equip_slot = get_exception(item.id)
      equip_slot = slot(name) if equip_slot == nil
      
      oldEquip = nil
      stackable = false
      
      if player.equipment.is_slot_used(equip_slot) && !stackable
        oldEquip = player.equipment.items[equip_slot]
        player.equipment.set equip_slot, nil
      end
      
      player.inventory.set slot, nil
      player.inventory.add oldEquip unless oldEquip == nil
      
      if stackable
        player.equipment.add item
      else
        player.equipment.set equip_slot, item
      end
    end
  end

  class AppearanceContainerListener < Calyx::Item::ContainerListener
    attr :player
    
    def initialize(player)
      @player = player
    end
    
    def slot_changed(container, slot)
      @player.flags.flag :appearance
    end
    
    def slots_changed(container, slots)
      @player.flags.flag :appearance
    end
    
    def items_changed(container)
      @player.flags.flag :appearance
    end
  end
  
  class SidebarContainerListener < Calyx::Item::ContainerListener
    MATERIALS ||= [
      "Iron", "Steel", "Scythe", "Black", "Mithril", "Adamant",
      "Rune", "Granite", "Dragon", "Crystal", "Bronze"
    ]
  
    attr :player
    
    def initialize(player)
      @player = player
    end
    
    def slot_changed(container, slot)
      send_weapon if slot == 3
    end
    
    def slots_changed(container, slots)
      slot = slots.find {|e| e == 3}
      send_weapon unless slot == nil
    end
    
    def items_changed(container)
      send_weapon
    end
    
    def send_weapon
      weapon = player.equipment.items[3]
      
      if weapon
        name = weapon.definition.name
        send_sidebar name, weapon.id, find_sidebar_interface(name)
      else
        # No weapon wielded
        @player.io.send_sidebar_interface 0, 5855
        @player.io.send_string 5857, "Unarmed"
      end
    end
    
    private
    
    def find_sidebar_interface(name)
      SIDEBARS.each {|matcher, data|
        formatted_name = data[:type] == :generic ? filter_name(name) : name
        
        if formatted_name =~ matcher
          return data[:id]
        end
      }
      
      2423
    end
    
    def send_sidebar(name, id, interface_id)
      @player.io.send_sidebar_interface 0, interface_id
      @player.io.send_interface_model interface_id+1, 200, id
      @player.io.send_string interface_id+3, name
    end
    
    def filter_name(name)
      name = name.dup
      MATERIALS.each {|m| name.gsub!(Regexp.new(m), "") }
      name.strip
    end
  end

  # Interface container sizes
  set_int_size(1688, 14)

  # Listener
  on_player_login(:equipment) do |player|
    # Have to send sidebar interfaces so the sidebar listener's update takes effect
    player.io.send_sidebar_interfaces
    
    # Register equipment container listeners
    player.equipment.add_listener Calyx::Item::InterfaceContainerListener.new(player, 1688)
    player.equipment.add_listener AppearanceContainerListener.new(player)
    player.equipment.add_listener SidebarContainerListener.new(player)
    player.equipment.add_listener Calyx::Item::WeightListener.new(player)
    player.equipment.add_listener Calyx::Item::BonusListener.new(player)
  end

  # Wield item
  on_item_wield(3214) do |player, item, slot, name, id|
    if id == 4079 # Loop yo-yo
      player.play_animation Calyx::Model::Animation.new(1458) 
    elsif id == 6865 # Walk Marrionette(blue)
      player.play_animation Calyx::Model::Animation.new(3004)
      player.play_graphic Calyx::Model::Graphic.new(512, 2)
    elsif id == 6866 # Walk Marrionette(green)
      player.play_animation Calyx::Model::Animation.new(3004)
      player.play_graphic Calyx::Model::Graphic.new(516, 2)
    elsif id == 6867 # Walk Marrionette(red)
      player.play_animation Calyx::Model::Animation.new(3004)
      player.play_graphic Calyx::Model::Graphic.new(508, 2)
    else
      equip player, item, slot, name, id
    end
  end

  # Unwield item
  on_item_option(1688) do |player, id, slot|
    Calyx::Item::Container.transfer player.equipment, player.inventory, slot, id
  end
end