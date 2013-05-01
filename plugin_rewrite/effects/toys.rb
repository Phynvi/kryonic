plugin :effects do

  # Toys (marionettes, spinning plates, etc.)
  on_load do
    toys = load_yaml("toys.yaml")

    toys.each do |item|
      method("on_#{item[:hook]}").call(item[:id]) do |player, slot|
        if item.include?(:animation)
          player.play_animation Calyx::Model::Animation.new(item[:animation], 0)
        end

        if item.include?(:graphic)
          player.play_graphic Calyx::Model::Graphic.new(item[:graphic], item[:delay] || 0)
        end
      end
    end
  end

  # Toy horses
  horse_phrases = [
    "Come on Dobbin, we can win the race!",
    "Hi-ho Silver, and away!",
    "Neaahhhyyy! Giddy-up horsey!"
  ]

  (2520..2526).step(2) do |id|
    on_item_click(id) do |player, slot|
      player.force_chat(horse_phrases[rand(horse_phrases.size)])
      player.play_animation(Calyx::Model::Animation.new(918 + (id - 2520) / 2))
    end
  end
end