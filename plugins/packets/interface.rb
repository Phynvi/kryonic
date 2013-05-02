# Action buttons
on_packet(185) do |player, packet|
  button = packet.read_short

  handler = HOOKS[:int_button][button]
  
#  if handler.instance_of?(Proc)
#    handler.call(player)
#  else
#    Logging.logger['packets'].warn "Unhandled action button: #{button}"
#  end

  Calyx::Plugins.run_hook(:int_button, button, [player])
end

# Enter amount
# TODO Reset interface ID at end
on_packet(208) do |player, packet|
  amount = packet.read_int
  
  if player.interface_state.enter_amount_open?
    enter_amount_slot = player.interface_state.enter_amount_slot
    enter_amount_id = player.interface_state.enter_amount_id
    
    Calyx::Plugins.run_hook(
      :int_enteramount,
      [player.interface_state.enter_amount_interface],
      [player, enter_amount_id, enter_amount_slot, amount]
    )
  end
end

# Close interface
on_packet(130) do |player, packet|
  handler = HOOKS[:int_close][player.interface_state.current_interface]
  
  if handler.instance_of?(Proc)
    handler.call(player)
  else 
    player.interface_state.interface_closed
  end
end