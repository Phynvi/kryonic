plugin :woodcutting do
  
  on_load do
    @axes = load_yaml("axes.yaml")
    @trees = load_yaml("trees.yaml")

    # Hook each tree object ID
    @trees.each do |tree|
      tree[:objects].each do |id|
        on_obj_option(id) do |player, loc|
          # Change object test
          object = Calyx::Objects::Object.new(1342, loc, 0, 10, 1278, loc, 0, 3)
          object.change
          WORLD.object_manager.objects << object

          # Enqueue action
          player.action_queue.add WoodcuttingAction.new(player, loc, tree)
        end
      end
    end
  end

  def find_axe(player, level)
    @axes.find do |h, v|
      player.equipment.contains(h) || player.inventory.contains(h) && level >= v[:level]
    end
  end

  class WoodcuttingAction < Calyx::Actions::HarvestingAction
    attr_accessor :cycle_count
    attr_accessor :tree
    attr_accessor :axe
    
    def initialize(player, loc, tree)
      super(player, loc)
      @tree = tree
      @cycle_count = 0
    end
     
    def init
      level = player.skills.skills[:woodcutting]
      
      # Check if we have a axe we can use
      @axe = find_axe(player, level)
      
      # Replace with value (hash)
      @axe = @axe[1] unless @axe == nil
      
      if @axe == nil
        player.io.send_message "You do not have an axe for which you have the level to use."
        stop
        return
      end
      
      # Check if we can cut this tree
      if level < @tree[:level]
        player.io.send_message "You do not have the required level to cut down this tree."
        stop
        return
      end
      
      player.io.send_message "You swing your axe at the tree..."
      @cycle_count = calculate
    end
    
    def calculate
      wc = player.skills.skills[:woodcutting]
      @cycle_count = ((@tree[:level] * 60 - wc * 20) / @axe[:level] * 0.25 - rand(3) * 4).ceil
      @cycle_count = 1 if @cycle_count < 1
      @cycle_count.to_i
    end
    
    def harvested_item; Calyx::Item::Item.new(@tree[:log], 1) end
    
    def experience; @tree[:xp] end
    
    def animation; Calyx::World::Animation.new(@axe[:animation]) end
    
    def skill; :woodcutting end
    
    def harvest_delay; 3000 end
    
    def periodic_rewards; true end
    
    def factor; 0.5 end
    
    def cycles; @tree[:level] == 1 ? 1 : @cycle_count end
  end
end