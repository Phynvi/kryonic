plugin :horses do
  phrases = [
    "Come on Dobbin, we can win the race!",
    "Hi-ho Silver, and away!",
    "Neaahhhyyy! Giddy-up horsey!"
  ]

  (2520..2526).step(2) do |id|
    on_item_click(id) do |player, slot|
      player.force_chat(phrases[rand(phrases.size)])
      player.play_animation(Calyx::Model::Animation.new(918 + (id - 2520) / 2))
    end
  end
end