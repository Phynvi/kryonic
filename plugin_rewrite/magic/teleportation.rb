plugin :magic do

  # Load teleport button data from file
  on_load do
    data = load_yaml("teleport_data.yaml")

    data.each do |teleport|
      on_int_button(teleport[:button]) do |player|
        player.teleport_location = Calyx::Model::Location.new(*teleport[:location])
      end
    end
  end
end