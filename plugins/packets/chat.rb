require 'shellwords'

# Chat
on_packet(4) do |player, packet|
  effect = packet.read_byte_s.ubyte
  color = packet.read_byte_s.ubyte
  size = packet.buffer.size
      
  # Prevent message flooding
  #next if player.chat_queue.size >= @@queue_size
      
  # Unpack string
  copy = Calyx::Net::Packet.new(nil, nil, packet.buffer.clone)
  raw_data = copy.read_bytes(size).unpack("C" * size)
  chat_data = (0...size).collect { |i| (raw_data[size - i - 1] - 128).byte }
  message = Calyx::Misc::TextUtils.unpack(chat_data, chat_data.size)
  message = Calyx::Misc::TextUtils.filter(message)
  message = Calyx::Misc::TextUtils.optimize(message)
  
  default = true
  
  Calyx::Plugins.run_hook(:chat, nil, [player, effect, color, message]) do |block, block_args|
    default &= block.call(*block_args) != :nodefault
  end

  # Send to all clients
  if default
    packed = Calyx::Misc::TextUtils.repack(size, packet)
    packed = packed.pack("C" * packed.size)
    player.chat_queue << Calyx::Model::ChatMessage.new(color, effect, packed)
  end
end

# Command
on_packet(103) do |player, packet|
  command = packet.read_str
  params = Shellwords.shellwords command
  name = params[0].downcase
  params.shift
  
  begin
    Calyx::Plugins.run_hook(:command, name, [player, params])
  rescue Exception => e
    player.io.send_message "Command error:"
    player.io.send_message "#{$!}"
    
    log = Logging.logger['packets']
    log.error "Command error"
    log.error e
  end
end