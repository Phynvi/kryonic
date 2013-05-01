plugin :bank do

  # TODO Refactor withdraw() and deposit()

  # Interface container sizes
  set_int_size(5382, 352)
  set_int_size(5064, 28)

  # Mode buttons
  on_int_button(5386) { |player| player.settings[:withdraw_note] = true }

  on_int_button(5387) { |player| player.settings[:withdraw_note] = false }

  on_int_button(8130) { |player| player.settings[:swapping] = true }

  on_int_button(8131) { |player| player.settings[:swapping] = false }

  # Enter amount for withdraw and deposit
  on_int_enter_amount(5064) do |player, id, slot, amount|
    deposit(player, slot, id, amount)
  end

  on_int_enter_amount(5382) do |player, id, slot, amount|
    withdraw(player, slot, id, amount)
  end

  # Bank booth object
  on_obj_option2(6084) { |player, loc| open(player) }

  # Withdraw item
  on_item_option(5382)  { |player, id, slot| withdraw(player, slot, id, 1) }

  on_item_option2(5382) { |player, id, slot| withdraw(player, slot, id, 5) }

  on_item_option3(5382) { |player, id, slot| withdraw(player, slot, id, 10) }

  on_item_option4(5382) do |player, id, slot|
    withdraw(player, slot, id, player.bank.count(id))
  end

  # Deposit item
  on_item_option(5064)  { |player, id, slot| deposit(player, slot, id, 1) }

  on_item_option2(5064) { |player, id, slot| deposit(player, slot, id, 5) }

  on_item_option3(5064) { |player, id, slot| deposit(player, slot, id, 10) }

  on_item_option4(5064) do |player, id, slot|
    deposit(player, slot, id, player.inventory.count(id))
  end

  # Swap item
  on_item_swap(5064) do |player, fromSlot, toSlot|
    player.inventory.swap(fromSlot, toSlot)
  end

  # Bank command
  on_command("bank") do |player, params|
    r = Random.new

    (0..20).each do 
      player.bank.add Calyx::Item::Item.new(r.rand(1040...1056))
    end

    open(player)
  end

  # Open bank interface
  def open(player)
    player.bank.remove_empty_slots
    player.io.send_interface_inventory(5292, 5063)
    player.interface_state.add_listener(player.bank, Calyx::Item::InterfaceContainerListener.new(player, 5382))
    player.interface_state.add_listener(player.inventory, Calyx::Item::InterfaceContainerListener.new(player, 5064))
  end

  # Deposit item
  def deposit(player, slot, id, amount)
    inv_firing_events = player.inventory.fire_events
    player.inventory.fire_events = false
    
    begin 
      item = player.inventory.items[slot]
      
      return unless item != nil   # Invalid packet, or client out of sync
      return unless item.id == id # Invalid packet, or client out of sync
      
      transfer_amount = player.inventory.count(id)
      if transfer_amount >= amount
        transfer_amount = amount
      end
      
      return unless transfer_amount != 0 # Invalid packet, or client of out sync
      
      noted = item.definition.noted
      if (item.definition.stackable || false) || (item.definition.noted || false)
        banked_id = if noted then item.definition.parent else item.id end

        if player.bank.free_slots < 1 && player.bank.item_for_id(banked_id) == nil
          player.io.send_message "You don't have enough space in your bank account."
        end
        
        # we only need to remove from one stack
        new_inv_amount = item.count - transfer_amount
        new_item = nil
        if new_inv_amount > 0
          new_item = Calyx::Item::Item.new item.id, new_inv_amount
        end
        if !player.bank.add Calyx::Item::Item.new(banked_id, transfer_amount)
          player.io.send_message "You don't have enough space in your bank account."
        else
          player.inventory.set slot, new_item
          player.inventory.fire_items_changed
          player.bank.fire_items_changed
        end
      else
        if player.bank.free_slots < transfer_amount
          player.io.send_message "You don't have enough space in your bank account."
        end

        if !player.bank.add Calyx::Item::Item.new(item.id, transfer_amount)
          player.io.send_message "You don't have enough space in your bank account."
        else
          (0...transfer_amount).each do |i|
            player.inventory.set player.inventory.slot_for_id(item.id), nil
          end

          player.inventory.fire_items_changed
        end
      end
    ensure
      player.inventory.fire_events = inv_firing_events
    end
  end

  # Withdraw item
  def withdraw(player, slot, id, amount)
    item = player.bank.items[slot]
    
    return unless item != nil   # Invalid packet or client out of sync
    return unless item.id == id # Invalid packet or client out of sync
    
    transfer_amount = item.count
    if transfer_amount >= amount
      transfer_amount = amount
    end
    
    return unless transfer_amount != 0 # Invalid packet or client out of sync
    
    new_id = item.id # TODO deal with withdraw as notes
    if (player.settings[:withdraw_note] || false)
      if item.definition.noteable
        new_id = item.definition.noteID
      end
    end
    
    definition = Calyx::Item::ItemDefinition.for_id new_id
    if (definition.stackable || false) || (definition.noted || false)
      if player.inventory.free_slots <= 0 && player.inventory.item_for_id(new_id) == nil
        player.io.send_message "You don't have enough inventory space to withdraw that many."
      end
    else
      free = player.inventory.free_slots

      if transfer_amount > free
        player.io.send_message "You don't have enough inventory space to withdraw that many."
        transfer_amount = free
      end
    end
    
    # Add item(s) to inventory
    if player.inventory.add Calyx::Item::Item.new(new_id, transfer_amount)
      new_amount = item.count - transfer_amount

      if new_amount <= 0
        player.bank.set slot, nil
      else
        player.bank.set slot, Calyx::Item::Item.new(item.id, new_amount)
      end
    else
      player.io.send_message "You don't have enough inventory space to withdraw that many."
    end
  end
end