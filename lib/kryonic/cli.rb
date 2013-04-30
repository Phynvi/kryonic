require 'optparse'

def usage
  $stderr.puts <<EOF

This is a command line tool for Kryonic. More information about Kryonic can
be found at http://kryonic.com/

== Commands

All commands are executed as kryonic [options] command [command-options] args

The following commands are available:

help                                    # Show this usage

info                                    # Show your account information

create name                             # Create a new project with given name

deploy                                  # Deploy server to Kryonic

server                                  # Start the server locally

Please see the Kryonic documentation at http://kryonic.com/documentation/ for additional
information on the commands that are available to Kryonic customers.

EOF
end

if $0.split("/").last == 'kryonic'

  options = {}

  subcommands = {
    'info'   => OptionParser.new,
    'create' => OptionParser.new,
    'deploy' => OptionParser.new,
    'server' => OptionParser.new
  }

  command = ARGV.shift
  if command == 'help'
    usage
  else
    options_parser = subcommands[command]
    options_parser.order! if options_parser
    
    puts "Command: #{command}"
    
    if command == 'server'
      require 'calyx'

      WORLD = Calyx::World::World.new
      SERVER = Calyx::Server.new
      SERVER.start_config(Calyx::Misc::HashWrapper.new({:port => 43594}))
    end
    
#    begin
#      cli.execute(command, ARGV, options)
#    rescue Kryonic::CommandNotFound => e
#      puts e.message
#    end
  end
end