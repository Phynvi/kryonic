plugin :userinterface do

  # Disable chat if player is muted
  on_chat(:mute) do |player, effect, color, message|
    if player.settings[:muted]
      :nodefault
    end
  end

  # Send message on login
  on_player_login(:mute) do |player|
    if player.settings[:muted]
      player.io.send_message "You have been muted for breaking a rule."
    end
  end
end