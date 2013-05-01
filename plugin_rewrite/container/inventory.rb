plugin :container do

  # Interface container sizes
  set_int_size(3214, 28)

  # Item swap
  on_item_swap(3214) do |player, from_slot, to_slot|
    player.inventory.swap(from_slot, to_slot)
  end

  # Listener
  on_player_login(:inventory) do |player|
    player.inventory.add_listener Calyx::Item::InterfaceContainerListener.new(player, 3214)
    player.inventory.add_listener Calyx::Item::WeightListener.new(player)
  end
end