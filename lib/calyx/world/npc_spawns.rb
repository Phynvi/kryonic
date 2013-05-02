module Calyx::World

  class NPCSpawns

    DIRECTIONS = {
      :north => [0, 1],
      :south => [0, -1],
      :east => [1, 0],
      :west => [-1, 0],
      :northeast => [1, 1],
      :northwest => [-1, 1],
      :southeast => [1, -1],
      :southwest => [-1, -1]
    }
    
    def NPCSpawns.load
      npc = XmlSimple.xml_in("data/npc_spawns.xml")
      npc["npc"].each_with_index { |row, idx| NPCSpawns.spawn(row) }
    end
    
    def NPCSpawns.spawn(data)
      npc = Calyx::NPC::NPC.new Calyx::NPC::NPCDefinition.for_id(data['id'].to_i)
      npc.location = Calyx::Model::Location.new(data['x'].to_i, data['y'].to_i, data['z'].to_i)
        
      WORLD.register_npc npc
      
      if data.include?('face')
        npc.direction = data['face'].to_sym
        
        offsets = DIRECTIONS[npc.direction]
        npc.face(npc.location.transform(offsets[0], offsets[1], 0))
      end
    end
  end
end