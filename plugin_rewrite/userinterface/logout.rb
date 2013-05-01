plugin :userinterface do

  # Logout button
  on_int_button(2458) { |player| player.io.send_logout }
end