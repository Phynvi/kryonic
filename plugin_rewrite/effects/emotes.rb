plugin :effects do
  
  # Emote buttons
  on_load do
    emotes = load_yaml("emotes.yaml")

    emotes.each do |button, anim|
      on_int_button(button) do |player|
        player.play_animation Calyx::Model::Animation.new(anim)
      end
    end
  end
end