# Object option 1
on_packet(132) do |player, packet|
  x = packet.read_leshort_a.ushort
  id = packet.read_short.ushort
  y = packet.read_short_a.ushort
  loc = Calyx::Model::Location.new x, y, player.location.z
  next unless player.location.within_interaction_distance?(loc)

  Calyx::Plugins.run_hook(:obj_click1, id, [player, loc])
end

# Object option 2
on_packet(252) do |player, packet|
  id = packet.read_leshort_a.ushort
  y = packet.read_leshort.ushort
  x = packet.read_short_a.ushort
  loc = Calyx::Model::Location.new x, y, player.location.z
  next unless player.location.within_interaction_distance?(loc)
  
  Calyx::Plugins.run_hook(:obj_click2, id, [player, loc])
end

# Object option 3
on_packet(70) do |player, packet|
  handler = HOOKS[:obj_click3][id]

  Calyx::Plugins.run_hook(:obj_click3, id, [player])              
end